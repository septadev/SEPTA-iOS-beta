//
//  CommentsForm.h
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface CommentsFormTemp : NSObject <FXForm>


@property (nonatomic, copy) NSString *when;

@property (nonatomic, copy) NSString *where;
@property (nonatomic, copy) NSString *mode;

@property (nonatomic, copy) NSString *routes;

//@property (nonatomic, assign) NSUInteger field1;
//@property (nonatomic, assign) NSUInteger field2;

-(BOOL) validateForm;

//+(NSArray*) returnAllKeyValues;
//+(NSArray*) returnAllRequiredValues;

@end
