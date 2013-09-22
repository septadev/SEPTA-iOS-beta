//
//  ShowTimesStartCell.m
//  iSEPTA
//
//  Created by septa on 11/5/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "ShowTimesStartCell.h"

@implementation ShowTimesStartCell
{

}

@synthesize lblStopName;
@synthesize btnFlip;
@synthesize btnLeft;

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

- (IBAction)leftButtonTapped:(id)sender
{
//    NSLog(@"STSC - left button tapped");
    if ( [self.delegate respondsToSelector:@selector(leftButtonPressedInRow:)] )
        [[self delegate] leftButtonPressedInRow:row];
}

- (IBAction)flipButtonTapped:(id)sender
{
//    NSLog(@"STSC - flip button tapped");
    if ( [self.delegate respondsToSelector:@selector(flippedButtonPressed)] )
        [[self delegate] flippedButtonPressed];
}

-(void) flipDataInCell: (ShowTimesStartCell*) firstCell withCell: (ShowTimesStartCell*) secondCell
{
    NSString *tmpStr = [[firstCell lblStopName] text];
    [[firstCell lblStopName] setText: [[secondCell lblStopName] text] ];
    [[secondCell lblStopName] setText:tmpStr];
}

-(void) flipDataWithCell:(ShowTimesStartCell *)secondCell
{
    NSString *tmpStr = [[self lblStopName] text];
    [[self lblStopName] setText: [[secondCell lblStopName] text] ];
    [[secondCell lblStopName] setText:tmpStr];
    
}

//-(NSString*) description
//{
//    return [NSString stringWithFormat:@"Stop name: %@", [[self lblStopName] text] ];
//}

@end
