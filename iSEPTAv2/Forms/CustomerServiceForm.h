//
//  CustomerServiceForm.h
//  iSEPTA
//
//  Created by septa on 1/7/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

#import "GTFSCommon.h"

// -- Pods --
#import "FMDatabase.h"



@interface CustomerServiceForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *date;

@property (nonatomic, copy) NSString *where;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, copy) NSString *route;
@property (nonatomic, copy) NSString *destination;

@property (nonatomic, copy) NSString *comment;

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *emailAddress;

-(BOOL) validateForm;
+(NSArray*) returnAllKeyValues;
+(NSArray*) returnAllRequiredValues;

@end
