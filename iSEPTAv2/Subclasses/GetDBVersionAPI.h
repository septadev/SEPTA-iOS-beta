//
//  GetDBVersionAPI.h
//  iSEPTA
//
//  Created by septa on 1/6/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

// --==  PODs  ==--
#import <AFNetworking.h>
#import <Reachability.h>

@interface DBVersionDataObject : NSObject

@property (nonatomic, strong) NSString *md5;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *effective_date;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *change_log;

@end

@protocol GetDBVersionDataAPIProtocol <NSObject>

@optional
-(void) dbVersionFetched:(DBVersionDataObject*) obj;

@end


@interface GetDBVersionAPI : NSObject

@property (nonatomic, weak) id <GetDBVersionDataAPIProtocol> delegate;
@property (nonatomic, strong, readonly) NSString *localMD5;

-(void) fetchData;
-(DBVersionDataObject*) getData;
-(NSString*) loadLocalMD5;

@end
