//
//  TableCellAlertsView.m
//  iSEPTA
//
//  Created by septa on 4/17/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import "TableCellAlertsView.h"

#define DEFAULTDURATION 1.0f
#define DEFAULTDELAY    0.5f
#define DEFAULT_REFRESH_RATE 1.75f

/*
 
 This is a UIView either displays a single image or animates threw multiple images.
 If all alerts have been removed or no alerts were added, the view should be hidden.
 
 
 */


/* Generated from: www.kammerl.de/ascii/AsciiSignature.php, Font: Georgia11
 
                   ,,        ,,                               ,,    ,,                  ,,                                            ,,
 MMP""MM""YMM     *MM      `7MM            .g8"""bgd        `7MM  `7MM        db      `7MM                    mm        `7MMF'   `7MF'db
 P'   MM   `7      MM        MM          .dP'     `M          MM    MM       ;MM:       MM                    MM          `MA     ,V
      MM   ,6"Yb.  MM,dMMb.  MM  .gP"Ya  dM'       ` .gP"Ya   MM    MM      ,V^MM.      MM  .gP"Ya `7Mb,od8 mmMMmm ,pP"Ybd VM:   ,V `7MM  .gP"Ya `7M'    ,A    `MF'
      MM  8)   MM  MM    `Mb MM ,M'   Yb MM         ,M'   Yb  MM    MM     ,M  `MM      MM ,M'   Yb  MM' "'   MM   8I   `"  MM.  M'   MM ,M'   Yb  VA   ,VAA   ,V
      MM   ,pm9MM  MM     M8 MM 8M"""""" MM.        8M""""""  MM    MM     AbmmmqMA     MM 8M""""""  MM       MM   `YMMMa.  `MM A'    MM 8M""""""   VA ,V  VA ,V
      MM  8M   MM  MM.   ,M9 MM YM.    , `Mb.     ,'YM.    ,  MM    MM    A'     VML    MM YM.    ,  MM       MM   L.   I8   :MM;     MM YM.    ,    VVV    VVV
    .JMML.`Moo9^Yo.P^YbmdP'.JMML.`Mbmmd'   `"bmmmd'  `Mbmmd'.JMML..JMML..AMA.   .AMMA..JMML.`Mbmmd'.JMML.     `MbmoM9mmmP'    VF    .JMML.`Mbmmd'     W      W
 
 */
@implementation TableCellAlertsView
{
//    NSMutableArray *_imageViewArray;
    NSMutableArray *_imageArray;
    
//    UIImageView *_mainImageView;
//    UIImageView *_imageView;
    
    NSTimer *_runLoopTimer;
    
    CGFloat _duration;
    CGFloat _delay;
    
    CGFloat _refreshRate;
    
    NSInteger _index;
    
    BOOL _isRunning;
    BOOL _hasSideIndex;
    
    NSMutableArray *_alertsToRemove;
    
}

@synthesize imageView = _imageView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void) awakeFromNib
{
    
//    NSLog(@"TCAV - awakeFromNib");
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
//        NSLog(@"TCAV - initWithCoder");
        // Initialization code
        _imageArray     = [[NSMutableArray alloc] init];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.frame];
        
        self.hidden = YES;  // Default state is hidden
        [self setBackgroundColor: [UIColor colorWithWhite:0.0f alpha:0.0f]];
        
        _index = 0;
        _isRunning = NO;
        _hasSideIndex = NO;
        
        _duration = DEFAULTDURATION;
        _delay    = DEFAULTDELAY;
        
        _refreshRate = _duration + _delay;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        // Initialization code
        _imageArray     = [[NSMutableArray alloc] init];
        
//        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView = [[UIImageView alloc] init];
        
        self.hidden = YES;  // Default state is hidden
        [self setBackgroundColor: [UIColor colorWithWhite:0.0f alpha:0.0f]];
        
        _index = 0;
        _isRunning = NO;
        _hasSideIndex = NO;
        
        _duration = DEFAULTDURATION;
        _delay    = DEFAULTDELAY;
        
        _refreshRate = _duration + _delay;
        
    }
    return self;
    
}


-(void) hasSideIndex:(BOOL)yesNO
{
    _hasSideIndex = yesNO;
//    if (yesNO)
//        [_imageView setFrame:CGRectMake(self.frame.origin.x - 10, self.frame.origin.y, 20, 15) ];
//    else
//        [_imageView setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 40, 30) ];
//    
//    [_imageView setContentMode:UIViewContentModeScaleAspectFit];

}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


-(void) addAlert: (TableCellAlertsImageType) alertType
{
    
    UIImage *alertImg;
    
    switch ( (TableCellAlertsImageType)alertType )
    {
        case kTableCellAlertsImageAlerts:
            alertImg = [UIImage imageNamed:@"system_status_alert.png"];
            break;
            
        case kTableCellAlertsImageAdvisories:
            alertImg = [UIImage imageNamed:@"system_status_advisory.png"];
            break;
            
        case kTableCellAlertsImageDetours:
            alertImg = [UIImage imageNamed:@"system_status_detour.png"];
            break;
            
        case kTableCellAlertsImageSuspend:
            alertImg = [UIImage imageNamed:@"system_status_suspended.png"];
            break;
            
        default:
            break;
    }
    
    
    if ( alertImg != nil )
    {
        
        [_imageArray addObject: alertImg];
//        [self setHidden:NO];

        if ( [_imageArray count] == 1 )  // If there's only one image, there's no need for animation.  Just display it.
        {
            
            if ( _hasSideIndex )
                [_imageView setFrame:CGRectMake(0, 7.5, 20, 15)];
            else
                [_imageView setFrame:CGRectMake(0, 0, 40, 30)];
            
            [_imageView setImage: alertImg];
            [self addSubview: _imageView];
            [self setHidden:NO];
        }
        else
        {
            [self startLoop];
        }
        
    }
    
    
    // This is not the optimal method for handling things.  It will create n UIImageView, whereas the optimal method requires
    //   only 2, the image that's at zero alpha and the image that's at 1.
//    if ( alertImg != nil )
//    {
//        UIImageView *alertImageView = [[UIImageView alloc] initWithFrame: CGRectMake(23, -2, 40/2.0f, 30/2.0f) ];
//        [alertImageView setImage: alertImg];
//        
//        if ( [_imageViewArray count] == 0 )
//            [alertImageView setAlpha: 1.0f];
//        else
//            [alertImageView setAlpha:0.0f];
//        
//        [alertImageView setTag: alertType];
//        
//        //        [_mainImageView addSubview: alertImageView];
//        [_baseButton addSubview: alertImageView];
//        
//        [_imageViewArray addObject: alertImageView];
//        NSLog(@"AlertImageView: %@", alertImageView);
//    }
    
//    [self startLoop];
    
}


-(void) removeAlert: (TableCellAlertsImageType) alertType
{
    
    NSUInteger index;
    UIImage *alertImg;
    
    switch ( (TableCellAlertsImageType)alertType )
    {
        case kTableCellAlertsImageAlerts:
            alertImg = [UIImage imageNamed:@"system_status_alert.png"];
            break;
            
        case kTableCellAlertsImageAdvisories:
            alertImg = [UIImage imageNamed:@"system_status_advisory.png"];
            break;
            
        case kTableCellAlertsImageDetours:
            alertImg = [UIImage imageNamed:@"system_status_detour.png"];
            break;
            
        case kTableCellAlertsImageSuspend:
            alertImg = [UIImage imageNamed:@"system_status_suspended.png"];
            break;
            
        default:
            break;
    }
    
    
    index = [_imageArray indexOfObject:alertImg];
    if ( index == NSNotFound )  // If alert isn't in _imageArray then there's nothing to remove
        return;
        
    if ( _alertsToRemove == nil )
        _alertsToRemove = [[NSMutableArray alloc] init];
    
    // Ensure the view isn't already slated to be removed
    if ( ![_alertsToRemove containsObject: alertImg] )
        [_alertsToRemove addObject: alertImg];
    
}



-(void) removeAllAlerts
{
    [self stopLoop];
    [_imageView setImage:nil];  // Remove image from _imageView
    
    [_imageArray removeAllObjects];
    [_imageView removeFromSuperview];
}

-(void) incrementIndex
{
    _index = (_index+1) % [_imageArray count];
    
//    if (_index < ([_imageViewArray count] -1 ) )
//        _index++;
//    else
//        _index = 0;
    
}


-(void) nextLoop
{
    
//    UIImageView *imageA;
//    UIImageView *imageB;

    UIImage *imageA;
    UIImage *imageB;
    

    // Any alerts to be removed?
    if ( _alertsToRemove )
    {
        // Yes!
        [_imageArray removeObjectsInArray: _alertsToRemove];
    }
    
    NSInteger arraySize = [_imageArray count];
    
    // Checks
    if ( arraySize == 0 )
    {
        [self stopLoop];
    }
    else if ( arraySize == 1 )
    {
        // Only one image, always keep this active
        imageA = (UIImage*)[_imageArray objectAtIndex:0];
        [_imageView setImage:imageA];
        
        [self stopLoop];  // Stop the animation
    }
    else
    {
        
        [self incrementIndex];
        imageB = [_imageArray objectAtIndex:_index];
        
        [UIView transitionWithView:_imageView
                          duration:_duration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            NSLog(@"TCAV - Animation started.");
                            [_imageView setImage:imageB];
                        }
                        completion:^(BOOL finished) {
                            NSLog(@"TCAV - Animation finished.");
                        }];
        
    }
    
}

-(void) startLoop
{
    
    if ( _isRunning )
        return;
    
    _runLoopTimer = [NSTimer scheduledTimerWithTimeInterval:_refreshRate
                                                     target:self
                                                   selector:@selector(nextLoop)
                                                   userInfo:nil
                                                    repeats:YES];
    
    _isRunning = YES;
    
    
}

-(void) stopLoop
{
    _isRunning = NO;
    
    if ( _runLoopTimer != nil )
        [_runLoopTimer invalidate];
}


-(void) setDuration:(int) duration
{
    _duration = duration;
    [self updateRefreshRate];
}


-(void) setDelay:(int) delay
{
    _delay = delay;
    [self updateRefreshRate];
}

-(void) updateRefreshRate
{
    _refreshRate = _duration + _delay;
}


//-(void) setBaseImage: (UIImage*) image
//{
//    //    [_mainImageView setImage: image];
//    [_baseButton setImage:image forState:UIControlStateNormal];
//}
//
//
//-(void) addTarget:(id) target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
//{
//    
//    [_baseButton addTarget:target action:action forControlEvents:controlEvents];
//    
//}





@end
