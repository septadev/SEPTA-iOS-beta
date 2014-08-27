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
    
    BOOL _testMode;
    
}

@synthesize localMD5 = _localMD5;

-(id) init
{
    

    if ( (  self = [super init] ) )
    {
        _testMode = NO;  // Defaults to NO
    }
    return self;
    
}


-(id) initWithTestMode:(BOOL) yesNO
{
    
    if ( (  self = [super init] ) )
    {
        _testMode = yesNO;
    }
    return self;

}

-(void) setTestMode:(BOOL) yesNO
{
    _testMode = yesNO;
}

-(void) fetchData
{
    
    if ( ![[Reachability reachabilityForInternetConnection] isReachable] )
        return;


    NSString *url;
    
    if ( _testMode )
    {
        url = @"http://api0.septa.org/gga8893/dbVersion/";
    }
    else
    {
        url = @"http://www3.septa.org/hackathon/dbVersion/";        
    }


    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:url] ];
    
    _jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

                                                                          NSDictionary *jsonDict = (NSDictionary*) JSON;
//                                                                         NSMutableDictionary *jsonDict = [(NSDictionary *) JSON mutableCopy];
//                                                                         [jsonDict setValue:@"high" forKey:@"severity"];
//                                                                         [jsonDict setValue:@"This is a test message that I am going to display. Sometimes there is a lot to say and it requires a longer time for the reader to get through the entire things.  Hopefully this will cap out the message at the 15 sec mark." forKey:@"message"];
                                                                         
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
            NSLog(@"GetDBVersionAPI processDBVersionJSON exception for key %@: %@", key, exception);
//            NSLog(@"Looking for %@ in the JSON", key);
        }

    }];
    
    _dbObject = dbObject;
    NSLog(@"%@", dbObject);
    
    
    if ( [self.delegate respondsToSelector: @selector(dbVersionFetched:)] )
        [self.delegate dbVersionFetched: _dbObject];
    
    
}


-(DBVersionDataObject*) getData
{
    
    return _dbObject;
}


-(NSString*) loadLocalMD5
{
    
    _localMD5 = nil;

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [NSString stringWithFormat:@"%@/SEPTA.sqlite", [paths objectAtIndex:0] ];
    
    bool b = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];

    if ( !b )  // If the file does not exist
        dbPath = [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
    
    
    //    NSData *fileData = [NSData dataWithContentsOfFile: [GTFSCommon filePath] ];
    NSData *fileData = [NSData dataWithContentsOfFile: dbPath ];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(fileData.bytes, fileData.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    _localMD5 = output;
    
    
//    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *md5Path = [NSString stringWithFormat:@"%@/SEPTA.md5", [paths objectAtIndex:0] ];
//    
//    if ( md5Path == nil )
//        return nil;
//    
//    NSString *md5JSON = [[NSString alloc] initWithContentsOfFile:md5Path encoding:NSUTF8StringEncoding error:NULL];
//    if ( md5JSON == nil )
//        return nil;
//    
//    NSError *error = nil;
//    NSDictionary *md5dict = [NSJSONSerialization JSONObjectWithData: [md5JSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//    
//    if ( error != nil )
//        return nil;
//    
//    NSArray *md5Arr = [md5dict valueForKeyPath:@"md5"];
    
//    _localMD5 = [md5Arr firstObject];
    
//    NSLog(@"localMD5: %@", _localMD5);
    
    return _localMD5;
    
}



@end