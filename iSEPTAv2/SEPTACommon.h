//
//  SEPTACommon.h
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#ifndef iSEPTA_SEPTACommon_h
#define iSEPTA_SEPTACommon_h

typedef NS_ENUM(NSInteger, SEPTARouteTypes)  // According to the GTFS guidelines
{
    kSEPTATypeTrolley   = 0,
    kSEPTATypeMFL       = 1,
    kSEPTATypeRail      = 2,
    kSEPTATypeBus       = 3,
    kSEPTATypeNHSL      = 4,
    kSEPTATypeBSL       = 5,
    kSEPTATypeTracklessTrolley,
};


typedef NS_ENUM(NSInteger, TransitServiceStatus)
{
    kTransitServiceIn,
    kTransitServiceOut,
};

#endif
