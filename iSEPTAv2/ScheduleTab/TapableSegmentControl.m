//
//  TapableSegmentControl.m
//  iSEPTA
//
//  Created by septa on 11/5/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TapableSegmentControl.h"

@implementation TapableSegmentControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // Checks if oldIndex is the same as the newIndex.  If so, send the UIControlEventValueChanged action to the parent UISegmentedControl
    
//    NSLog(@"TSC -(void) touchesBegan");
    int oldIndex = self.selectedSegmentIndex;
    
    [super touchesBegan:touches withEvent:event];
    
    if ( oldIndex == self.selectedSegmentIndex)
    {
//        [super setSelectedSegmentIndex:UISegmentedControlNoSegment];  // Uncomment to allow SegmentedControl to be deselected
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
