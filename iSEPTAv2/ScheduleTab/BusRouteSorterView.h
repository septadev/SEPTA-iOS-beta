//
//  BusRouteSorterViewController.h
//  iSEPTA
//
//  Created by septa on 10/18/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BusRouteSorterProtocol <NSObject>
@required
-(void) filterHasChanged:(int) index;

@end


@interface BusRouteSorterView : UIView
{
    UIView *view;
}

@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *btnRouteFilter;
//@property (strong, nonatomic) IBOutlet UIView *view;

@end

