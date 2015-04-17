//
//  AlertMessage.h
//  iSEPTA
//
//  Created by septa on 4/9/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertMessage : NSObject

//@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSString *rect;
@property (strong, nonatomic) NSAttributedString *attrText;
@property (strong, nonatomic) NSString *text;

-(void) updateAttrText;

@end
