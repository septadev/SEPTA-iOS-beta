//
//  StopSequenceCell.m
//  iSEPTA
//
//  Created by septa on 11/29/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "StopSequenceCell.h"

//static int _startSequence;
//static int _endSequence;

@implementation StopSequenceCell
{
    BOOL _isHighlighted;
    float _imageHeight;

    int _startSequence;
    int _endSequence;
    int _currentSequence;
    
    StopSequenceCellData *_seqData;
    StopSequenceObject *_ssObject;
}


@synthesize lblStopName;
@synthesize lblStopTime;

@synthesize imgSequence;
@synthesize imgProgress;

@synthesize longPressGesture;
@synthesize doubleTapGesture;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        _isHighlighted = NO;
        
        // TODO: Don't hard code this value
        _imageHeight = 44.0f;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setHighlight:(BOOL) yesNO
{
    _isHighlighted = yesNO;
}


-(void) setStart:(int) start andEndSequence:(int) end
{
    _startSequence = start;
    _endSequence   = end;
}


-(void) setSequenceData:(StopSequenceCellData *)data forCurrentSequence:(NSNumber *)current
{
    
    _seqData = data;
    _currentSequence = [current intValue];
    
    
    [self setImage];
    
}


-(void) setImage
{
    
    // Start row
    BOOL _highlightOn = NO;
    
    if ( (_currentSequence >= [_seqData.startOfTrip intValue]) && (_currentSequence <= [_seqData.endOfTrip intValue]) )
    {
        _highlightOn = YES;
    }
    
    
    if ( [_seqData.firstSequence intValue] == _currentSequence )  // Top Bubble Logic
    {
        if ( _highlightOn )
            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceTopHighBubble.png"] ];
        else
            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceTopBubble.png"] ];
    }
    else if ( [_seqData.lastSequence intValue] == _currentSequence ) // Bottom Bubble Logic
    {
        UIImage *tempSeq;
        if ( _highlightOn )
            tempSeq = [UIImage imageNamed:@"stopSequenceTopHighBubble.png"];
        else
            tempSeq = [UIImage imageNamed:@"stopSequenceTopBubble.png"];
        
        [self.imgSequence setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
    }
    else if ( _currentSequence == [_seqData.startOfTrip intValue] )  // Middle Bubble Logic for Start
    {
            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"] ];
   } 
    else if ( _currentSequence == [_seqData.endOfTrip intValue] )  // Middle Bubble Logic for End
    {
        UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"];
        [self.imgSequence setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
    }
    else  // Middle Bubble Logic When Between Start and End
    {
        // Just display the normal MidHigh
        if ( _highlightOn )
            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidHighBubble.png"] ];
        else
            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];
    }
    
} // -(void) setImage


/*
 
 kFirstRow,        A or B depending on highlight
 kBeforeStart,     E
 kStart,           B if 1st row, G if not
 kBetweenStartEnd, H
 kEnd,             D if last row, F if not
 kAfterEnd,        E
 kLastRow          C or D depending on highlight
 
 */

/*
 
 currentSequence: x
 sequence range: NSRange( start_location, length )
 
 */

//-(void) setImageInSequence:(NSInteger)
//{
//    
//}


-(void) setProgress:(float) percentage
{

    // Bascially, percentage will be between 0 and 1, where 0 is imgProcess is completely hidden and 1 is imgSequence is completely hidden.
    // 0.5 would mean that imgProcess upper half is shown while half of imgSequence is shown
    _imageHeight = 44.0f;
    
    CGRect framePro = [self.imgProgress frame];
    framePro.size.height = _imageHeight * percentage;
    [self.imgProgress setFrame: framePro];
    
    CGRect frameSeq = [self.imgSequence frame];
    frameSeq.origin.y = framePro.origin.y + framePro.size.height;
    frameSeq.size.height = _imageHeight * percentage;
    [self.imgSequence setFrame: frameSeq];
    
    NSLog(@"SSC - framePro: %@, frameSeq: %@", NSStringFromCGRect(framePro), NSStringFromCGRect(frameSeq));
    
}


-(void) setImageForSequence:(NSInteger) currentSequence isFirst:(BOOL) isFirstYesNO orIsLast:(BOOL) isLastYesNO
{
    
    if ( isLastYesNO )
    {
        if ( currentSequence != _endSequence )
        {
            // C
            UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceTopBubble.png"];
            [self.imgSequence setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
        }
        else
        {
            // D
            UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceTopHighBubble.png"];
            UIImage *tempPro = [UIImage imageNamed:@"stopSequenceTopGreenBubble.png"];
            [self.imgSequence setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
            [self.imgProgress setImage: [UIImage imageWithCGImage: tempPro.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
        }

        return;
    }


    // Start row
    if ( isFirstYesNO )
    {
        
        // A or B depending on highlighted
        if ( currentSequence != _startSequence )
        {
            // A
            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceTopBubble.png"] ];
        }
        else
        {
            // B
            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceTopHighBubble.png"] ];
            [self.imgProgress setImage: [UIImage imageNamed:@"stopSequenceTopGreenBubble.png"] ];
        }
        return;
        
    }
    
    if ( currentSequence < _startSequence )
    {
        // E as long as currentSequence before _startSequence
        [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];

    }
    else if ( currentSequence == _startSequence )
    {
        // G
        [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"] ];
        [self.imgProgress setImage: [UIImage imageNamed:@"stopSequenceMidGreenDownBubble.png"] ];
    }
    else if ( currentSequence < _endSequence )
    {
        // H
        [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidHighBubble.png"] ];
        [self.imgProgress setImage: [UIImage imageNamed:@"stopSequenceMidGreenBubble.png"] ];
    }
    else if ( currentSequence == _endSequence )
    {
        // F
        UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"];
        UIImage *tempPro = [UIImage imageNamed:@"stopSequenceMidGreenDownBubble.png"];
        [self.imgSequence setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
        [self.imgProgress setImage: [UIImage imageWithCGImage: tempPro.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
    }
    else
    {
        // E
        [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];
    }
    
    
}


//-(void) changeImageTo:(NSIndexPath*) indexPath
//-(void) changeImageTo:(StopSequenceDefaultCellImageType) imageType
//{
//    
//    switch (imageType)
//    {
//        case kStopSequenceTopBubble:
//            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceTopBubble.png"] ];
//            break;
//        case kStopSequenceMidBubble:
//            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];
//            break;
//        case kStopSequenceBtmBubble:
//        {
//            //            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceBtmBubble.png"] ];
//            UIImage *temp = [UIImage imageNamed:@"stopSequenceTopBubble.png"];
//            [self.imgSequence setImage: [UIImage imageWithCGImage: temp.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
//        }
//            break;
//        case kStopSequenceTopHighBubble:
//            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceTopHighBubble.png"] ];
//            break;
//        case kStopSequenceMidHighUpBubble:
//        {
//            UIImage *temp = [UIImage imageNamed:@"stopSequenceMidHighDown.png"];
//            [self.imgSequence setImage: [UIImage imageWithCGImage: temp.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored]];
//        }
//            break;
//        case kStopSequenceMidHighDownBubble:
//            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"] ];
//            break;
//        case kStopSequenceBtmHighBubble:
//            [self.imgSequence setImage: [UIImage imageNamed:@"stopSequenceBtmHighBubble.png"] ];
//            break;
//        default:
//            [self.imgSequence setImage: nil];
//    }
//
//    
//}


//-(void) changeImageTo:(StopSequenceDefaultCellImageType) imageType
//{
//
//    [self changeImageTo:imageType withHighlighting:NO];
//    
//}


- (IBAction)gestureRecognizer:(id)sender
{

    NSLog(@"SSC - gesture recognized");
    
    if ( sender == longPressGesture )
    {
        if ( [self.delegate respondsToSelector:@selector(longPressRecognized)] )
            [[self delegate] longPressRecognized];
    }
    else if ( sender == doubleTapGesture )
    {
        if ( [self.delegate respondsToSelector:@selector(doubleTapRecognized)] )
            [[self delegate] doubleTapRecognized];
    }

}


-(NSString*) description
{
    return [NSString stringWithFormat:@"SSC - (%d) Stop name: %@ (%d), stop time: %@, coor: (%@, %@)", [_ssObject.stopSequence intValue], _ssObject.stopName, [_ssObject.stopID intValue], _ssObject.arrivalTime, _ssObject.stopLat, _ssObject.stopLon ];
}


#pragma mark - Alarm Button
- (IBAction)btnAlarmPressed:(id)sender
{
    
//    if ( [self.btnAlarm isHidden] == YES )
//    {
//        [self.btnAlarm setHidden:NO];
//    }
//    else
//    {
//        [self.btnAlarm setHidden:YES];
//    }

}

-(void) setAlarm
{
    [self.btnAlarm setHidden:NO];
}

-(void) clearAlarm
{
    [self.btnAlarm setHidden:YES];
}

-(void) loadObject:(StopSequenceObject *)ssObject
{
    lblStopName.text = ssObject.stopName;
    lblStopTime.text = ssObject.arrivalTime;
    
    _ssObject = ssObject;
}

-(CLLocationCoordinate2D) getLoc
{
    CLLocationCoordinate2D loc;
    loc.longitude = [_ssObject.stopLon floatValue];
    loc.latitude  = [_ssObject.stopLat floatValue];
    return loc;
}

@end
