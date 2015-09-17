//
//  GTFSCommon.h
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#ifndef iSEPTA_GTFSCommon_h
#define iSEPTA_GTFSCommon_h


// --==  Pods  ==--
#import <FMDatabase.h>
#import <ZipArchive.h>
// --==  Pods  ==--


typedef NS_ENUM(NSInteger, RoutesRouteType)  // According to the GTFS guidelines
{
    kRouteTypeTrolley   = 0,
    kRouteTypeSubway    = 1,
    kRouteTypeRail      = 2,
    kRouteTypeBus       = 3,
    kRouteTypeFerry     = 4,
    kRouteTypeCableCar  = 5,
    kRouteTypeGondola   = 6,
    kRouteTypeFunicular = 7,
};


typedef NS_ENUM(NSInteger, GTFSRouteType)  // According to the GTFS guidelines
{
    kGTFSRouteTypeTrolley   = 0,
    kGTFSRouteTypeSubway    = 1,
    kGTFSRouteTypeRail      = 2,
    kGTFSRouteTypeBus       = 3,
    kGTFSRouteTypeFerry     = 4,
    kGTFSRouteTypeCableCar  = 5,
    kGTFSRouteTypeGondola   = 6,
    kGTFSRouteTypeFunicular = 7,
};

typedef NS_ENUM(NSInteger, GTFSCalendarOffset)
{
    kGTFSCalendarOffsetToday,
    kGTFSCalendarOffsetTomorrow,
    kGTFSCalendarOffsetYesterday,
    kGTFSCalendarOffsetWeekday,
    kGTFSCalendarOffsetSat,
    kGTFSCalendarOffsetSun,
};

@interface GTFSCommon : NSObject
{
    
}

+(NSString*) filePath;

+(NSInteger) isHoliday:(GTFSRouteType) routeType withOffset:(GTFSCalendarOffset) offset;
+(NSString *) nextHoliday;


+(NSArray*) getServiceIDFor:(GTFSRouteType) route  withOffset:(GTFSCalendarOffset) offset;
+(NSString*) getServiceIDStrFor:(GTFSRouteType) route  withOffset:(GTFSCalendarOffset) offset;

+(BOOL) checkService:(int) serviceID withArray:(NSArray *)serviceIDArray;
+(BOOL) checkService:(int) serviceID withService:(int) otherID;

+(BOOL) isServiceGood:(int) serviceID forRouteType:(GTFSRouteType) routeType withOffset:(GTFSCalendarOffset) offset;
+(BOOL) date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

@end

#endif
