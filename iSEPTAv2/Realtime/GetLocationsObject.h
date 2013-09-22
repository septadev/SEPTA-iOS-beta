//
//  GetLocationsObject.h
//  iSEPTA
//
//  Created by septa on 1/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationData : NSObject
{

}

@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSString *location_name;

@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;

@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *address2;

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;

@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *hours;

@property (nonatomic, strong) NSString *loc_name;
@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSString *phone;

+(NSArray*) allKeys;

@end

@interface GetLocationsObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSString *location_name;

@property (nonatomic, strong) NSString *location_lat;
@property (nonatomic, strong) NSString *location_lon;

@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *location_type;

@property (nonatomic, strong) NSString *routeStr;

@property (nonatomic, strong) LocationData *location_data;

+(NSArray*) allKeys;

@end
