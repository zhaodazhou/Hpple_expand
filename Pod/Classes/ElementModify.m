//
//  ElementModify.m
//  StockMaster
//
//  Created by m11 on 2017/5/31.
//  Copyright © 2017年 wind. All rights reserved.
//

#import "ElementModify.h"



NSArray * delElementNodeTags(void);
NSArray * delAttributeTags(void);
void processImgTag(xmlNodePtr currentNode);

static NSArray * nodeTags;
static NSArray * attributeTags;

bool delElement(xmlNodePtr currentNode)
{
    if (currentNode == NULL) {
        return false;
    }
    
    NSLog(@"currentNode->name: %s", currentNode->name);
    
    if (currentNode->name && !xmlStrcmp(currentNode->name, (const xmlChar *)"a")) { // 对a标签做特殊处理，只保留内容，其他属性去掉
        xmlNodePtr newNode = xmlNewNode(NULL, (const xmlChar *)"text");
        xmlChar * content = xmlNodeGetContent(currentNode);
        xmlNodeSetContent(newNode, content);
        
        xmlReplaceNode(currentNode, newNode);
        
        return false;
    }
    
    if (currentNode->name && !xmlStrcmp(currentNode->name, (const xmlChar *)"img")) { // 对img标签做特殊处理
        processImgTag(currentNode);
        
        return false;
    }
    
    NSArray * nodeTagArr = delElementNodeTags();
    for (NSString * name in nodeTagArr) {
        const char * tmp = [name UTF8String];

        if (currentNode->name && !xmlStrcmp(currentNode->name, (const xmlChar *)tmp)) {
            NSLog(@"delete node: %@", name);
            xmlUnlinkNode(currentNode);
            xmlFreeNode(currentNode);
            return true;
        }
    }

    return false;
}

bool delAttribute(xmlAttr * attribute)
{
    NSLog(@"attribute->name: %s", attribute->name);
    NSArray * attributeTagArr = delAttributeTags();
    for (NSString * name in attributeTagArr)
    {
        const char * tmp = [name UTF8String];
         
        if (attribute->name && !xmlStrcmp((const xmlChar *)tmp, (const xmlChar *)attribute->name)) {
            NSLog(@"delete attribute: %@", name);
            
            return true;
        }
    }

    return false;
}

// 对img标签做特殊处理，去掉width与height属性，并对url补全
void processImgTag(xmlNodePtr currentNode)
{
    xmlAttr *attribute = currentNode->properties;
    while (attribute) {
        if (attribute->name && (!xmlStrcmp((const xmlChar *)"width", (const xmlChar *)attribute->name) || !xmlStrcmp((const xmlChar *)"height", (const xmlChar *)attribute->name)) ) {
            xmlAttr * tmp = attribute;
            attribute = attribute->next;
            
            xmlRemoveProp(tmp);
            continue;
        }
        else if (attribute->name && !xmlStrcmp((const xmlChar *)"src", (const xmlChar *)attribute->name)) {
            xmlChar* srcValue = xmlGetProp(currentNode, (const xmlChar*)"src");
            NSString * imgSrc = [NSString stringWithUTF8String:(const char *)srcValue];
            
            if ([imgSrc hasPrefix:@"http"]) {
                attribute = attribute->next;
                continue;
            }
            NSString * comImgPath;
            NSString * url = @"this is the url";
            if ([imgSrc hasPrefix:@"//"]) {
                NSString * urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL * mUrl = [NSURL URLWithString:urlStr];
                comImgPath = [NSString stringWithFormat:@"%@:%@", mUrl.scheme, imgSrc];
            }
            else if ([imgSrc hasPrefix:@"/"]) {
                NSString * urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL * mUrl = [NSURL URLWithString:urlStr];
                comImgPath = [NSString stringWithFormat:@"%@://%@%@", mUrl.scheme, mUrl.host, imgSrc];
            }
            else {
                long index = 0;
                for (index = url.length - 1; index >= 0; index --) {
                    unichar temp = [url characterAtIndex:index];
                    if (temp == '/') {
                        break;
                    }
                }
                
                if (index == 0) {
                    continue;
                }
                
                NSString * subStr = [url substringToIndex:index];
                comImgPath = [NSString stringWithFormat:@"%@/%@", subStr, imgSrc];
            }
            if (comImgPath && comImgPath.length > 0) {
                const char * tmp = [comImgPath UTF8String];
                xmlSetProp(currentNode, (const xmlChar*)"src", (const xmlChar*)tmp);
            }
        }
        attribute = attribute->next;
    }
}

NSArray * delElementNodeTags(void)
{
    if (nodeTags == NULL) {
        nodeTags = [NSArray arrayWithObjects:
                    // 特定标签过滤
                    @"iframe",
                    @"script",
                    @"style",
                    @"input",
                    @"select",
                    @"footer",
                    @"comment",
                    @"textarea",
                    nil];
    }
    return nodeTags;
}

NSArray * delAttributeTags(void)
{
    if (attributeTags == NULL) {
        attributeTags = [NSArray arrayWithObjects:
                         // 特定属性过滤
//                         @"href",
                         @"style",
                         @"class",
                         @"id",
                         @"onchange",
                         @"onsubmit",
                         @"onreset",
                         @"onselect",
                         @"onblur",
                         @"onfocus",
                         @"onkeydown",
                         @"onkeypress",
                         @"onkeyup",
                         @"onclick",
                         @"ondblclick",
                         @"onmousedown",
                         @"onmousemove",
                         @"onmouseout",
                         @"onmouseover",
                         @"onmouseup",
                        
                         nil];
    }
    return attributeTags;
}




