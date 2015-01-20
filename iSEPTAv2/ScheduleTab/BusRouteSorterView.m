//
//  BusRouteSorterViewController.m
//  iSEPTA
//
//  Created by septa on 10/18/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "BusRouteSorterView.h"

@implementation BusRouteSorterView

@synthesize btnRouteFilter;
@synthesize delegate;
//@synthesize view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
//        [[NSBundle mainBundle] loadNibNamed:@"BusRouteSorter" owner:self options:nil];
//
//        self.view.frame = self.frame;
//        self.view.autoresizingMask = self.autoresizingMask;
//        [self addSubview:self.view];
        
    }
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    
//    [[NSBundle mainBundle] loadNibNamed:@"BusRouteSorter" owner:self options:nil];
//
//    self.view.frame = self.frame;
//    self.view.autoresizingMask = self.autoresizingMask;
//    [self addSubview:self.view];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)changeFilterSelection:(id)sender
{
    NSLog(@"changeFilterSelection");
    if ( [self.delegate respondsToSelector:@selector(filterHasChanged:)] )
        [[self delegate] filterHasChanged: (int)btnRouteFilter.selectedSegmentIndex];
}



@end
