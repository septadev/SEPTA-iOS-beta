//
//  CommentsForm.h
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface CommentsForm : NSObject <FXForm>


@property (nonatomic, copy) NSString *dateTime;
//@property (nonatomic, copy) NSString *time;

@property (nonatomic, copy) NSString *where;
@property (nonatomic, copy) NSString *mode;

@property (nonatomic, copy) NSString *route;
@property (nonatomic, copy) NSString *destination;

@property (nonatomic, copy) NSString *blockTrain;
@property (nonatomic, copy) NSString *vehicle;

@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *employee_description;

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *emailAddress;

@end
