//
//  StopTimesCell.m
//  iSEPTA
//
//  Created by apessos on 12/11/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "StopTimesCell.h"

@implementation StopTimesCell

//@synthesize lblStopName;
//@synthesize btnFlipStopNames;
//@synthesize btnGetStopNames;

@synthesize row;
@synthesize delegate;

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


- (IBAction)getStopNamesButtonTapped:(id)sender
{
//    NSLog(@"STSC - left button tapped");
    if ( [self.delegate respondsToSelector:@selector(getStopNamesButtonPressed:)] )
        [[self delegate] getStopNamesButtonPressed: row];
}

- (IBAction)flipStopNamesButtonTapped:(id)sender
{
//    NSLog(@"STSC - flip button tapped");
    if ( [self.delegate respondsToSelector:@selector(flipStopNamesButtonPressed)] )
        [[self delegate] flipStopNamesButtonPressed];
}

-(void) flipDataInCell: (StopTimesCell*) firstCell withCell: (StopTimesCell*) secondCell
{
//    NSString *tmpStr = [[firstCell lblStopName] text];
//    [[firstCell lblStopName] setText: [[secondCell lblStopName] text] ];
//    [[secondCell lblStopName] setText:tmpStr];
}

-(void) flipDataWithCell:(StopTimesCell *)secondCell
{
//    NSString *tmpStr = [[self lblStopName] text];
//    [[self lblStopName] setText: [[secondCell lblStopName] text] ];
//    [[secondCell lblStopName] setText:tmpStr];
    
}


@end
