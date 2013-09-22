//
//  CCTParser.m
//  iSEPTA
//
//  Created by septa on 5/3/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CCTParser.h"

@implementation CCTParser
{
    
}

@synthesize html;

-(id) init
{
    
    if ( ( self = [super init] ) )
    {
        [self fetchCCTContent];
    }
    
    return self;
    
}


-(void) fetchCCTContent
{
 
    
    
    
    NSURL *webURL = [NSURL URLWithString:@"http://www.septa.org/service/cct/"];
    NSData *webData  = [NSData dataWithContentsOfURL: webURL];
    
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData: webData];
    
    NSString *XPathQueryString = @"//div[@id='septa_main_content']";
    NSArray *nodes = [htmlParser searchWithXPathQuery: XPathQueryString];
    
//    for (TFHppleElement *el in nodes)
//    {
//        NSLog(@"el: %@", el);
//    }
    
    TFHppleElement *el = (TFHppleElement*)[nodes objectAtIndex:0];
    html = el.raw;
    
    NSLog(@"CP: %@", html);
    
//    NSLog(@"CP: %@", [nodes objectAtIndex:0]);

    

    
//    NSString *webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: webStringURL]
//                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                         timeoutInterval:60.0f];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

//    NSError *error = nil;
//    NSString *stringURL = @"http://www.septa.org/service/cct/";
//    NSString *webURL = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:stringURL] encoding:NSUTF8StringEncoding error:&error];
    
//    if ( error != nil )
//    {
//        NSLog(@"Error: %@", error);
//        return nil;
//    }
    
    
//    parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:stringURL] ];
//    [parser setDelegate:self];
//    [parser parse];

    
//    if ( connection )
//    {
//        return [NSMutableData data];
//    }

//    return nil;

}

#pragma mark - NSXMLParser Delegate Methods
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"el: %@, attr: %@", elementName, attributeDict);
    NSLog(@"space: %@", namespaceURI);
    NSLog(@"qual : %@", qName);
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"char: %@", string);
}



@end
