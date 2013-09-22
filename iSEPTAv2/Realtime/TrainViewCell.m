//
//  TrainViewCell.m
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TrainViewCell.h"

@implementation TrainViewCell

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
        [[self lblStartName] setText: [object startName] ];
        [[self lblEndName  ] setText: [object endName  ] ];
        
        late = [[object late] intValue];
        
        //    [[self lblLate] setText: [NSString stringWithFormat:@"%d", [[object late] intValue] ] ];
        [[self lblTrainNo] setText: [object trainNo] ];
    }
    else if ([object isKindOfClass:[TransitViewObject class] ] )
    {
        [[self lblTrainNo] setText: [object VehicleID] ];

        late = [[object Offset] intValue];
        
//        if ( [[object Offset] intValue] > 0 )
//            [[self lblLate] setTextColor:[UIColor orangeColor] ];
//        else
//            [[self lblLate] setTextColor:[UIColor blackColor] ];
//        
//        if ( [[object Offset] intValue] > 5)
//            [[self lblLate] setTextColor:[UIColor redColor] ];
        
        
//        [[self lblLate] setText: [NSString stringWithFormat:@"%@ mins",[object Offset] ] ];
        //        [[cell lblStartName] setText: [NSString stringWithFormat:@"Bus %@", routeName] ];
        
        [[self lblStartTitle] setText:@"Dir:"];
        [[self lblEndTitle  ] setText:@"Dest:"];
        
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
        [[self lblLate] setTextColor: [UIColor blackColor] ];
    else if ( ( late > 0 ) && ( late <= 4) )
        [[self lblLate] setTextColor: [UIColor orangeColor] ];
    else if ( late > 4)
        [[self lblLate] setTextColor: [UIColor redColor] ];
    
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"startName: %@, endName: %@, late: %@, trainNo: %@", self.lblStartName.text, self.lblEndName.text, self.lblLate.text, self.lblTrainNo.text];
}


@end
