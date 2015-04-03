//
//  NextToArriveAlerts.h
//  iSEPTA
//
//  Created by septa on 4/3/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NextToArriveAlerts : UITableViewCell
{
    
}

@property (strong, nonatomic) NSNumber *numLines;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertText;

-(void) updateAlertTitle:(NSString*) title andText: (NSString*) text;

@end
