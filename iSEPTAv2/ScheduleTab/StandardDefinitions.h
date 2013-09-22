//
//  StandardDefinitions.h
//  iSEPTA
//
//  Created by septa on 11/16/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#ifndef iSEPTA_StandardDefinitions_h
#define iSEPTA_StandardDefinitions_h


typedef NS_ENUM(NSInteger, ShowTimesButtonPressed)
{
    kLeftButtonIsStart,
    kLeftButtonIsEnd,
    kLeftButtonIsUndefined,
};

typedef NS_ENUM(NSInteger, ShowTimesLocationType)
{
    kLocationOnlyHasStart,
    kLocationOnlyHasEnd,
    kLocationHasBoth,
    kLocationUndefined,
};


#endif
