//
//  DisplayTimesCell.m
//  iSEPTA
//
//  Created by septa on 11/8/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TripCell.h"

@implementation TripCell
{

    BOOL _hasStart;
    BOOL _hasEnd;
    
    BOOL _displayCountdown;
    BOOL _use24HourTime;
    
    NSString *arrivalTimeStr;
    NSString *departureTimeStr;
    
    int _arrivalTime;
    int _departureTime;
    
}


//@synthesize lblEndTime   = _lblEndTime;
//@synthesize lblStartTime = _lblStartTime;
@synthesize lblTimeBeforeArrival;

@synthesize lblTimeUntilEnd;
@synthesize lblUnitsUntilEnd;

@synthesize imageRightArrow;
//@synthesize btnAlarm;

@synthesize use24HourTime = _use24HourTime;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        _hasStart = NO;
        _hasEnd   = NO;
        _use24HourTime = YES;
        
        [self.lblNextDay setHidden:YES];
        
    }
    return self;
}


//-(void) setLblStartTime:(UILabel *)someLabel
//{
//
//    _lblStartTime = someLabel;
//    NSLog(@"someLabel text: %@", someLabel.text);
//    
//    NSLog(@"Hey!  Hey!  LblStartTime was just set!  Hey!  Hey!  Are you listening?");
//    NSLog(@"Hey!  Hey!  Remember how I was supposed to set LblStartTime?  Yea, I didn't feel like doing it.  Hey!  Hey!  What're you doing with that weapon?");
//
//}


//
//-(void) setLblEndTime:(UILabel *)someLabel
//{
//    _lblEndTime = someLabel;
//    departureTimeStr = someLabel.text;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) addArrivalTimeStr:(NSString*) arrivalStr
{
    
    arrivalTimeStr = arrivalStr;
    
    // Populates the arrival time label and calulates then populates the time before arrival label
    if ( _use24HourTime )
        [[self lblStartTime] setText: arrivalStr];
    else
    {
        NSArray *timeArray = [NSArray arrayWithArray: [arrivalStr componentsSeparatedByString:@":"] ];
        CFGregorianDate time;
        NSString *unit = @"am";
        
        time.hour   = [[timeArray objectAtIndex:0] intValue];
        time.minute = [[timeArray objectAtIndex:1] intValue];
        
        if ( ( time.hour >= 13 ) && ( time.hour <= 23 ) )
        {
            time.hour = time.hour % 12;
            unit = @"pm";
        }
        else if ( time.hour >= 24 )
        {
            time.hour -= 12;
        }
        else if ( time.hour == 12 )
        {
            unit = @"pm";
        }
        
        [[self lblStartTime] setText: [NSString stringWithFormat:@"%d:%02d%@", time.hour, time.minute, unit] ];
    }
    
//    [ [self lblTimeBeforeArrival] setText: [self calculateTimeDifferenceFromNowToTimeString: self.lblStartTime.text] ];
    if ( [arrivalStr length] > 0 )
        _hasStart = YES;
    
}

-(void) removeArrivalTimeStr
{
    [[self lblStartTime] setText:@""];
    _hasStart = NO;
    
}


-(void) addArrivalTime:(int) arrivalTime
{
    _arrivalTime = arrivalTime;
    [self updateLabel:self.lblStartTime withTime:arrivalTime];
}


-(void) addDepartureTime:(int) departureTime
{
    _departureTime = departureTime;
    [self updateLabel:self.lblEndTime withTime:departureTime];
}




-(void) updateLabel: (UILabel*) label withTime:(int) time
{

    int hour = time / 100;
    int min  = time % 100;

    if ( _use24HourTime )  // Time, by default, is always stored in military time
    {
        [ label setText: [NSString stringWithFormat:@"%02d:%02d",hour,min] ];
    }
    else
    {
        // When not using military time, mod the time by 24 and determine if it's in am or pm
        hour = hour % 24;
        NSString *unit;
        
        if ( hour < 12 )
        {
            unit = @"am";
            if ( hour == 0 )
                hour = 12;
        }
        else
        {
            unit = @"pm";

            if (hour != 12)
                hour = hour % 12;
        }
        
        [ label setText: [NSString stringWithFormat:@"%02d:%02d%@",hour, min, unit] ];
        
    }
    
}


-(void) addDepartureTimeStr:(NSString*) departureStr
{
    
    departureTimeStr = departureStr;
    [self.lblEndTime setText:departureTimeStr];
    
    if ( _use24HourTime )
        [[self lblEndTime] setText: departureStr];
    else
    {
        NSArray *timeArray = [NSArray arrayWithArray: [departureStr componentsSeparatedByString:@":"] ];
        CFGregorianDate time;
        NSString *unit = @"am";
        
        time.hour   = [[timeArray objectAtIndex:0] intValue];
        time.minute = [[timeArray objectAtIndex:1] intValue];

        if ( ( time.hour >= 13 ) && ( time.hour <= 23 ) )
        {
            time.hour = time.hour % 12;
            unit = @"pm";
        }
        else if ( time.hour >= 24 )
        {
            time.hour = time.hour % 12;
            if ( time.hour == 0 )
            {
                time.hour = 12;
            }
        }
        else if ( time.hour == 12 )
        {
            unit = @"pm";
        }
        
//        NSLog(@"Was- %d:%d\tIs- %d:%d", [[timeArray objectAtIndex:0] intValue], [[timeArray objectAtIndex:1] intValue], arrivalTime.hour, arrivalTime.minute);
        

        [[self lblEndTime] setText: [NSString stringWithFormat:@"%d:%02d%@", time.hour, time.minute, unit] ];
    }
    
    if ( [departureStr length] > 0 )
        _hasEnd = YES;
    
}

-(void) updateTimeFormats
{

//    [self addDepartureTimeStr: departureTimeStr];
//    [self addArrivalTimeStr  : arrivalTimeStr  ];
    
    [self addDepartureTime: _departureTime];
    [self addArrivalTime  : _arrivalTime  ];
    
}




-(void) removeDepartureTimeStr
{
    [[self lblEndTime] setText:@""];
    _hasEnd = NO;
}


-(NSString*) calculateTimeDifferenceFromNowToTimeString:(NSString*) str
{
    
    NSArray *timeArray = [NSArray arrayWithArray: [str componentsSeparatedByString:@":"] ];
    if ( [timeArray count] == 0 )
        return nil;
    
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), tz);
    CFRelease(tz);
    
    
    CFGregorianDate arrivalTime;
    
    arrivalTime.hour   = [[timeArray objectAtIndex:0] intValue];
    arrivalTime.minute = [[timeArray objectAtIndex:1] intValue];
    
    NSInteger diff = (arrivalTime.hour-currentDate.hour)*60 + (arrivalTime.minute-currentDate.minute);
    
    if ( diff < 0 )
        return nil;
    else if ( diff == 0 )
        return @"now!";
    
    if ( diff > 59 )
    {
        // Was "leaves in over %d hrs"
        return [NSString stringWithFormat:@"%d hrs %02ld mins", (int)diff/60, (long)diff % 60];
    }
    else
    {
        return [NSString stringWithFormat:@"%02ld mins", (long)diff];
    }

}

-(NSArray*) calculateTimeDifferenceFromTimeString:(NSString *)firstStr ToTimeString:(NSString *)secondStr
{
    
//    CFGregorianDate arrivalTime;
//    
//    arrivalTime.hour = [[timeArray objectAtIndex:0] intValue];
//    arrivalTime.minute = [[timeArray objectAtIndex:1] intValue];
    
    if ( ( firstStr == nil ) || ( secondStr == nil ) )
        return nil;
        
    NSArray *timeArray = [NSArray arrayWithArray: [firstStr componentsSeparatedByString:@":"] ];
    
//    if ( [timeArray count] < 2 )  // timeArray better be
//        return nil;
    
    NSInteger start = [[timeArray objectAtIndex:0] intValue] * 60 + [[timeArray objectAtIndex:1] intValue];
    
    timeArray = [NSArray arrayWithArray: [secondStr componentsSeparatedByString:@":"] ];
    NSInteger end   = [[timeArray objectAtIndex:0] intValue] * 60 + [[timeArray objectAtIndex:1] intValue];
    
    NSInteger diff = end - start;  // End will (SHOULD!) always be greater than Start
    
//    timeArray = [NSArray arrayWithArray: [secondStr componentsSeparatedByString:@":"] ];
//    CFGregorianDate departureTime;
//    
//    departureTime.hour = [[timeArray objectAtIndex:0] intValue];
//    departureTime.minute = [[timeArray objectAtIndex:1] intValue];
    
//    NSInteger diff = (arrivalTime.hour-departureTime.hour)*60 + (arrivalTime.minute-departureTime.minute);
    
//    CFGregorianDate newTime = CFAbsoluteTimeGetDifferenceAsGregorianUnits(arrivalTime, departureTime, nil, (kCFGregorianUnitsHours | kCFGregorianUnitsMinutes) );
    
    
//    if ( diff < 0 )
//        return [NSArray arrayWithObjects:@"", @"", nil];
    
    if ( diff < 0 )
        return nil;
    
    if ( diff > 119 )
    {
        return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", (int)diff/60], @"hours", nil];
    }
    else
    {
        return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", (long)diff], @"mins", nil];
    }
    
}

//static inline int mod(int x, int n)
//{
//    int r = x % n;
//    if ( r < 0 )
//    {
//        r += n;
//    }
//    return r;
//}

static inline int timeDiff(int a, int b)
{
    
    // Why did I change this again?  What was I on?
    int nowHr = a / 100;
    int arrHr = b / 100;

    int nowMn = a % 100;
    int arrMn = b % 100;
    
    int temp = (arrHr*60 + arrMn) - (nowHr*60 + nowMn);
//    int temp = 60 * ((b - a)/100) + ( (b - a) % 100);
    
    return temp;
//    return (temp/60)*100 + (temp%60);
    
//    return tempB;
    
    
//    int timeBefore = b - a;
//    
//    if ( nowHr != arrHr )
//    {
//        timeBefore -= 40 * (arrHr - nowHr);
//    }
    
//    int hour = timeBefore / 100;
//    int min  = timeBefore % 100;
    
//    return timeBefore;
    
}

-(void) updateCell
{
    
//    int timeLeft = _departureTime - _arrivalTime;
//    timeLeft -= (timeLeft / 60) * 40;  // Hours only go up to 59 before rolling over, decimals 99.  This corrects for that.
    
    int timeLeft = timeDiff(_arrivalTime, _departureTime);
    
    if ( timeLeft >= 0 )
        [[self lblTimeUntilEnd] setText: [NSString stringWithFormat:@"%d", timeLeft] ];
    else
        [[self lblTimeUntilEnd] setText: @""];
    
    // Hey, make sure that the imageRightArrow isn't hidden now!
    [[self imageRightArrow] setHidden:NO];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    int now = 0;  // Always show times greater than 00:00 unless a new time has been added.
    
    [dateFormatter setDateFormat:@"HHmm"];
    now = [[dateFormatter stringFromDate: [NSDate date] ] intValue];
    
    // Now, should we display a countdown?
    if ( _displayCountdown )
    {
        
        // Yes!  I knew I liked you.

        
//        int nowHr = now / 100;
//        int arrHr = _arrivalTime / 100;
//        
//        int timeBefore = _arrivalTime - now;
//        
//        if ( nowHr != arrHr )
//        {
//            timeBefore -= 40 * (arrHr - nowHr);
//        }

        int timeBefore = timeDiff(now, _arrivalTime);
        
        if ( timeBefore > 0 )
        {
            
//            int hour = timeBefore / 100;
//            int min  = timeBefore % 100;
            
            int hour = (timeBefore/60);
            int min  = (timeBefore%60);
            
            //        int timeBefore = _arrivalTime - now;
            //        timeBefore -= (timeBefore / 60) * 40;
            //        int hour = timeBefore / 60;
            //        int min  = timeBefore % 60;
            
            
            
            if ( hour == 1 )
                [[self lblTimeBeforeArrival] setText: [NSString stringWithFormat:@"%d hr %d mins", hour,  min] ];
            else if ( hour > 1 )
                [[self lblTimeBeforeArrival] setText: [NSString stringWithFormat:@"%d hrs %d mins", hour, min] ];
            else
            {
                if ( min == 1 )
                    [[self lblTimeBeforeArrival] setText: [NSString stringWithFormat:@"%d min", min] ];
                else
                    [[self lblTimeBeforeArrival] setText: [NSString stringWithFormat:@"%d mins", min] ];
            }
            
        }
        else
            [[self lblTimeBeforeArrival] setText: @""];
    
    }
    else
    {
        // Awww, you're a doody head.
        [[self lblTimeBeforeArrival] setText: @""];
    }
    
    return;
    
}


-(void) setDisplayCountdown:(BOOL)yesNO
{
    _displayCountdown = yesNO;
}

-(void) hideCell
{
    [[self imageRightArrow] setHidden:YES];
    [[self lblTimeBeforeArrival] setText:@""];
    [[self lblTimeUntilEnd] setText:@""];
    [[self lblUnitsUntilEnd] setText:@""];
    [[self lblStartTime] setText:@""];
    [[self lblEndTime] setText:@""];
//    [[self btnAlarm] setHidden:YES];
}

/*
 [[(DisplayTimesCell*)cell lblStartTime] setText: arrivalStr];
 [[(DisplayTimesCell*)cell imageRightArrow] setHidden:YES];
 [[(DisplayTimesCell*)cell lblTimeUntilEnd] setText:@""];
 [[(DisplayTimesCell*)cell lblUnitsUntilEnd] setText:@""];
 [[(DisplayTimesCell*)cell lblEndTime] setText:@""];
 
 CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
 NSArray *timeArray = [NSArray arrayWithArray: [arrivalStr componentsSeparatedByString:@":"] ];
 CFGregorianDate arrivalTime;
 
 arrivalTime.hour = [[timeArray objectAtIndex:0] intValue];
 arrivalTime.minute = [[timeArray objectAtIndex:1] intValue];
 
 NSInteger diff = (arrivalTime.hour-currentDate.hour)*60 + (arrivalTime.minute-currentDate.minute);
 NSLog(@"diff: %d", diff);
 
 if ( diff > 120 )
 {
 [[(DisplayTimesCell*)cell lblTimeBeforeArrival] setText: [NSString stringWithFormat:@"in over %d hrs", (int)diff/60] ];
 }
 else
 {
 [[(DisplayTimesCell*)cell lblTimeBeforeArrival] setText: [NSString stringWithFormat:@"in %d mins", diff] ];
 }
 */


#pragma mark - Alarm Button Press
- (IBAction)btnAlarmPressed:(id)sender
{
    
    if ( self.btnAlarm.alpha <= 0.21f )  // button has alpha applied, turn it full on!
    {
        [self.btnAlarm setAlpha:1.0f];
    }
    else
    {
        [self.btnAlarm setAlpha:0.2f];
    }
        
}




@end
