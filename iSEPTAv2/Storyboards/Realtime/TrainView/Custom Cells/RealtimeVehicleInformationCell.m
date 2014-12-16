//
//  RealtimeVehicleInformationCell.m
//  iSEPTA
//
//  Created by septa on 7/31/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "RealtimeVehicleInformationCell.h"

@implementation RealtimeVehicleInformationCell

@synthesize lblStartName;
@synthesize lblEndName;

@synthesize lblLate;
@synthesize lblTrainNo;

@synthesize lblStartTitle;
@synthesize lblEndTitle;


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

-(void) addObjectToCell:(id) object
{
    
    int late = 0;
    
    if ( [object isKindOfClass:[TrainViewObject class] ] )
    {
        
        [self setBackgroundColor:[UIColor purpleColor] ];
        
        UIColor *lblColor;
        if ( [[object trainNo] intValue] % 2 == 0 )
        {
            lblColor = [UIColor colorWithRed:179.0f/255.0f green:14.0f/255.0f blue:14.0f/255.0f alpha:1.0f];
        }
        else
        {
            lblColor = [UIColor colorWithRed:0.0f/255.0f green:125.0f/255.0f blue:195.0f/255.0f alpha:1.0f];
        }
        
        [[self lblStartName] setText: [object startName] ];
        [[self lblEndName  ] setText: [object endName  ] ];
        
        late = [[object late] intValue];
        [[self lblLate] setHidden:NO];
        
        //    [[self lblLate] setText: [NSString stringWithFormat:@"%d", [[object late] intValue] ] ];
        [[self lblTrainNo] setTextColor: lblColor];
        [[self lblTrainNo] setText: [object trainNo] ];
        
    }
    else if ([object isKindOfClass:[TransitViewObject class] ] )
    {
        [[self lblTrainNo] setText: [object VehicleID] ];
        
        late = [[object Offset] intValue];
        [[self lblLate] setHidden:YES];
        
        //        if ( [[object Offset] intValue] > 0 )
        //            [[self lblLate] setTextColor:[UIColor orangeColor] ];
        //        else
        //            [[self lblLate] setTextColor:[UIColor blackColor] ];
        //
        //        if ( [[object Offset] intValue] > 5)
        //            [[self lblLate] setTextColor:[UIColor redColor] ];
        
        
        //        [[self lblLate] setText: [NSString stringWithFormat:@"%@ mins",[object Offset] ] ];
        //        [[cell lblStartName] setText: [NSString stringWithFormat:@"Bus %@", routeName] ];
        
        UIColor *lblColor;
        if ( [[object Direction] isEqualToString:@"NorthBound"] ||  [[object Direction] isEqualToString:@"WestBound"] )
            lblColor = [UIColor colorWithRed:179.0f/255.0f green:14.0f/255.0f blue:14.0f/255.0f alpha:1.0f];
        else
            lblColor = [UIColor colorWithRed:0.0f/255.0f green:125.0f/255.0f blue:195.0f/255.0f alpha:1.0f];
        
        [[self lblStartTitle] setText:@"Dir:"];
        [[self lblEndTitle  ] setText:@"Dest:"];

        [[self lblStartName] setTextColor: lblColor];
        [[self lblStartName] setText: [object Direction] ];
        [[self lblEndName  ] setText: [object destination] ];
        
    }
    
    if ( late < 0 )
        late = 0;
    
    if ( late == 0 )
        [[self lblLate] setText: @"On-time"];
    else if ( late == 1 )
        [[self lblLate] setText: [NSString stringWithFormat:@"%d min", late]];
    else
        [[self lblLate] setText: [NSString stringWithFormat:@"%d mins", late]];
    
    if ( late == 0 )
        [[self lblLate] setTextColor: [UIColor colorWithRed:13.0/255.0 green:164.0/255.0 blue:74.0/255.0 alpha:1.0] ];
    else if ( ( late > 0 ) && ( late <= 4) )
        [[self lblLate] setTextColor: [UIColor redColor] ];  // Was orangeColor
    else if ( late > 4)
        [[self lblLate] setTextColor: [UIColor redColor] ];
    
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"startName: %@, endName: %@, late: %@, trainNo: %@", self.lblStartName.text, self.lblEndName.text, self.lblLate.text, self.lblTrainNo.text];
}


@end
