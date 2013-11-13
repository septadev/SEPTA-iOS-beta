//
//  DisplayTimesCell.h
//  iSEPTA
//
//  Created by septa on 11/8/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeBeforeArrival;

@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;

@property (weak, nonatomic) IBOutlet UIImageView *imageRightArrow;

@property (weak, nonatomic) IBOutlet UILabel *lblTimeUntilEnd;
@property (weak, nonatomic) IBOutlet UILabel *lblUnitsUntilEnd;

//@property (weak, nonatomic) IBOutlet UIButton *btnAlarm;

@property (nonatomic) BOOL use24HourTime;

@property (weak, nonatomic) IBOutlet UILabel *lblTrainNo;

@property (weak, nonatomic) IBOutlet UIButton *btnAlarm;
@property (weak, nonatomic) IBOutlet UILabel *lblNextDay;


//@property (weak, nonatomic) IBOutlet UIImageView *imgActiveAlarm;
//@property (weak, nonatomic) IBOutlet UIImageView *imgMyTrain;

-(void) addArrivalTime:(int) arrivalTime;
-(void) addDepartureTime:(int) departureTime;

-(void) addArrivalTimeStr:(NSString*) arrivalStr;
-(void) removeArrivalTimeStr;

-(void) addDepartureTimeStr:(NSString*) departureStr;
-(void) removeDepartureTimeStr;

//-(void) checkTravelTime;

-(NSString*) calculateTimeDifferenceFromNowToTimeString:(NSString*) str;
-(NSArray*)  calculateTimeDifferenceFromTimeString:(NSString*) firstStr ToTimeString:(NSString*) secondStr;

-(void) updateTimeFormats;

-(void) updateCell;
//-(void) updateLabel;
-(void) hideCell;

-(void) setDisplayCountdown:(BOOL) yesNO;

@end
