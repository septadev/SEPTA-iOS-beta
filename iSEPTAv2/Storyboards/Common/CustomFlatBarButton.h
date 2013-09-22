//
//  CustomBackBarButton.h
//  iSEPTA
//
//  Created by septa on 7/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol CustomBackBarButtonProtocol <NSObject>
//
//-(void) backButtonPressed:(id) sender;
//
//@end

@interface CustomFlatBarButton : UIBarButtonItem

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIButton *button;
//@property (nonatomic, weak) id <CustomBackBarButtonProtocol> delegate;

//-(id) initWithImageNamed:(NSString*) imageName withDelegate:(id) delegate;
-(id) initWithImageNamed:(NSString*) imageName withTarget:(id) delegate andWithAction:(SEL) sel;

@end
