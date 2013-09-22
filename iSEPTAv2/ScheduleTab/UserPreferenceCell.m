//
//  UserPreferenceCell.m
//  iSEPTA
//
//  Created by septa on 11/15/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "UserPreferenceCell.h"

@implementation UserPreferenceCell

@synthesize lblStartStopName;
@synthesize lblStart;
@synthesize lblEndStopName;
@synthesize lblEnd;

@synthesize lblFromTO;  // From is 1, TO is direction_id 0

@synthesize lblRouteShortName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"UPC - touchedBegan");
//}
//
//-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"UPC - touchesMoved");
//}
//
//-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"UPC - touchesEnded");
//}
//
//-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"UPC - touchesCancelled");
//}

@end
