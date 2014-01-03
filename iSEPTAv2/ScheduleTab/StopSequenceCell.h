//
//  StopSequenceCell.h
//  iSEPTA
//
//  Created by septa on 11/29/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopSequenceCellData.h"
#import "StopSequenceObject.h"

#import <CoreLocation/CLLocation.h>

typedef NS_ENUM(NSInteger, StopSequenceDefaultCellImageType)  // According to the GTFS guidelines
{
    kStopSequenceTopBubble = 0,
    kStopSequenceMidBubble = 1,
    kStopSequenceBtmBubble = 2,
    
    kStopSequenceTopHighBubble,
    kStopSequenceMidHighDownBubble,
    kStopSequenceMidHighUpBubble,
    kStopSequenceBtmHighBubble,
    
    kStopSequenceUndefined,
};



@interface StopSequenceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgSequence;
@property (weak, nonatomic) IBOutlet UIImageView *imgProgress;

@property (weak, nonatomic) IBOutlet UILabel *lblStopName;
@property (weak, nonatomic) IBOutlet UILabel *lblStopTime;

@property (weak, nonatomic) IBOutlet UIButton *btnAlarm;

@property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;

@property (weak, nonatomic) id delegate;

//@property (strong, nonatomic) StopSequenceObject *ssObject;

-(void) setHighlight:(BOOL) yesNO;
-(void) setStart:(int) start andEndSequence:(int) end;

//-(void) setStart:(int)start andEndSequence:(int)end andCurrentSequenece:(int) current;
-(void) setSequenceData:(StopSequenceCellData*) data forCurrentSequence:(NSNumber*) current;

-(void) setProgress:(float) percentage;

//-(void) changeImageTo:(StopSequenceDefaultCellImageType) imageType;
-(void) setImageForSequence:(NSInteger) currentSequence isFirst:(BOOL) isFirstYesNO orIsLast:(BOOL) isLastYesNO;
//-(void) changeImageTo:(NSIndexPath*) indexPath;

-(void) loadObject: (StopSequenceObject*) ssObject;

-(void) setAlarm;
-(void) clearAlarm;

-(CLLocationCoordinate2D) getLoc;

@end

@protocol StopSequenceProtocol

@required
-(void) doubleTapRecognized;
-(void) longPressRecognized;

@end
