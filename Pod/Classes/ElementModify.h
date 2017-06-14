//
//  ElementModify.h
//  StockMaster
//
//  Created by m11 on 2017/5/31.
//  Copyright © 2017年 wind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

bool delElement(xmlNodePtr currentNode);

bool delAttribute(xmlAttr * attribute);


