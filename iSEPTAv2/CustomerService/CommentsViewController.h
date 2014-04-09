//
//  CommentsViewController.h
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXForms.h"

#import "CommentsForm.h"

@interface CommentsViewController : UIViewController <FXFormControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;

@end
