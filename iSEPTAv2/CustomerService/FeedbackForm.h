//
//  FeedbackForm.h
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface FeedbackForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *feedbackType;
@property (nonatomic, copy) NSString *details;


@end
