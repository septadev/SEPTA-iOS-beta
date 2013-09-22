//
//  ScrollingTestViewController.h
//  iSEPTA
//
//  Created by septa on 12/11/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollingTestViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{

    // Public variables go here
    
}


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
