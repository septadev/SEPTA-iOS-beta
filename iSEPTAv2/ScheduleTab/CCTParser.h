//
//  CCTParser.h
//  iSEPTA
//
//  Created by septa on 5/3/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "TFHpple.h"

@interface CCTParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *parser;
    NSMutableString *element;
}

@property (strong, nonatomic) NSString *html;

@end
