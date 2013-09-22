//
//  CustomerService.h
//  iSEPTA
//
//  Created by Justin Brathwaite on 4/13/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerServiceViewController : UIViewController <UIAlertViewDelegate>
{
    IBOutlet UIButton *CallButton;
    IBOutlet UIButton *faceBookButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *YouTubeButton;
    IBOutlet UIButton *CommentFormButton;
    IBOutlet UIScrollView *scrollView;
}

@end
