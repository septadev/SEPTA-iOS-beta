//
//  CommentForm.h
//  iSEPTA
//
//  Created by Justin Brathwaite on 4/14/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentForm : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) UIPageControl *pagecontrol;
@property (nonatomic,retain) UIView *firstview;
@property (nonatomic,retain) UIView *secondview;
@property (nonatomic,retain) UIView *thirdview;
@property (nonatomic,retain) UITextField *Name;
@property (nonatomic,retain) UITextField *phoneNumber;
@property (nonatomic,retain) UITextField *emailAddress;
@property (nonatomic,retain) UITextView *details;
@property (nonatomic,retain) UIImage* picture;
@property (nonatomic,retain) UIImagePickerController* pic;
@end
