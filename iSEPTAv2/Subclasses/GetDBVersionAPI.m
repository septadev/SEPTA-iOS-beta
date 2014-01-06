//
//  GetDBVersionAPI.m
//  iSEPTA
//
//  Created by septa on 1/6/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "GetDBVersionAPI.h"

@implementation  DBVersionDataObject

@synthesize effective_date;
@synthesize md5;
@synthesize message;
@synthesize title;
@synthesize version;

-(NSString*) description
{
    return [NSString stringWithFormat:@"Effective: %@, version: %@, md5: %@, title: %@, message: %@", effective_date, version, md5, title, message];
}

@end


@implementation GetDBVersionAPI
{

    AFJSONRequestOperation *_jsonOperation;

    DBVersionDataObject *_dbObject;
    
}


-(void) fetchData
{
    
    NSString *url = @"http://www3.septa.org/hackathon/dbVersion/";
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:url] ];
    
    _jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                         
                                                                         NSDictionary *jsonDict = (NSDictionary *) JSON;
                                                                         [self processDBVersionJSON: jsonDict];
                                                                         
                                                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                                                                                 NSError *error, id JSON) {
                                                                         NSLog(@"Request Failure Because %@",[error userInfo]);
                                                                         // TODO:  Set error flag, call delegate's alertFetched
                                                                     }
                      ];
    
    [_jsonOperation start];
    
    
}

-(void) processDBVersionJSON: (NSDictionary*) jsonDict
{
 
    if ( jsonDict == nil )
        return;
    
    DBVersionDataObject *dbObject = [[DBVersionDataObject alloc] init];

    [jsonDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        [dbObject setValue:obj forKey:key];
    }];
    
    _dbObject = dbObject;
    
    
    if ( [self.delegate respondsToSelector: @selector(dbVersionFetched:)] )
        [self.delegate dbVersionFetched: _dbObject];
    
    
}


-(DBVersionDataObject*) getData
{
    
    return _dbObject;
}

@end
