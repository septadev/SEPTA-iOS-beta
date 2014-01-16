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
@synthesize change_log;

-(NSString*) description
{
    return [NSString stringWithFormat:@"Effective: %@, version: %@, md5: %@, title: %@, message: %@", effective_date, version, md5, title, message];
}

@end


@implementation GetDBVersionAPI
{

    AFJSONRequestOperation *_jsonOperation;

    DBVersionDataObject *_dbObject;
//    NSString *_localMD5;
    
}

@synthesize localMD5 = _localMD5;

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
        
        @try
        {
            [dbObject setValue:obj forKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"GetDBVersionAPI processDBVersionJSON exception: %@", exception);
//            NSLog(@"Looking for %@ in the JSON", key);
        }

    }];
    
    _dbObject = dbObject;
    
    
    if ( [self.delegate respondsToSelector: @selector(dbVersionFetched:)] )
        [self.delegate dbVersionFetched: _dbObject];
    
    
}


-(DBVersionDataObject*) getData
{
    
    return _dbObject;
}


-(NSString*) loadLocalMD5
{
    
    //    NSString *localMD5;
    
    NSString *md5Path = [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"md5"];
    if ( md5Path == nil )
        return nil;
    
    NSString *md5JSON = [[NSString alloc] initWithContentsOfFile:md5Path encoding:NSUTF8StringEncoding error:NULL];
    if ( md5JSON == nil )
        return nil;
    
    NSError *error = nil;
    NSDictionary *md5dict = [NSJSONSerialization JSONObjectWithData: [md5JSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    if ( error != nil )
        return nil;
    
    NSArray *md5Arr = [md5dict valueForKeyPath:@"md5"];
    
    _localMD5 = [md5Arr firstObject];
    
//    NSLog(@"localMD5: %@", _localMD5);
    
    return _localMD5;
}



@end
