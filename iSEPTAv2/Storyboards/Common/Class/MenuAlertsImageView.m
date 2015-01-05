//
//  MenuAlertsImageView.m
//  iSEPTA
//
//  Created by Administrator on 11/22/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MenuAlertsImageView.h"


/*
 
 This is a UIView that controls two image views.
 
 UIImageView *mainImage
 UIImageView *alertImage
 
 */

#define DEFAULTDURATION 1.0f
#define DEFAULTDELAY    0.5f
#define DEFAULT_REFRESH_RATE 1.75f


@implementation MenuAlertsImageView
{
    
//    NSLinkedList *_list;
    NSMutableArray *_imageViewArray;
    
    UIButton *_baseButton;
    UIImageView *_mainImageView;
    UIImageView *_overlayImageView;
    
    NSTimer *_runLoopTimer;
    
    CGFloat _duration;
    CGFloat _delay;
    
    CGFloat _refreshRate;
    
    NSInteger _index;
    
    BOOL _isRunning;
    
    NSMutableArray *_alertsToRemove;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    
        // Initialization code
        _imageViewArray = [[NSMutableArray alloc] init];
        
        _baseButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 5, 40, 30)];
//        [myButton addTarget:<#(id)#> action:<#(SEL)#> forControlEvents:<#(UIControlEvents)#>]
        
//        _mainImageView    = [[UIImageView alloc] initWithFrame: CGRectMake(0, 5, 40, 30)];
        _overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 40/2.0f, 30/2.0f)];
        
        [_baseButton addSubview: _overlayImageView];
        [self addSubview: _baseButton];
        
//        [_mainImageView addSubview: _overlayImageView];
//        [self addSubview: _mainImageView];
    
        _index = 0;
        _isRunning = NO;
        
        _duration = DEFAULTDURATION;
        _delay    = DEFAULTDELAY;
        
        _refreshRate = _duration + _delay;
        
        //_testView = [[UIView alloc] initWithFrame:CGRectMake(10, 260, 50, 37.5)];
        //UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 40, 30)];
        //UIImageView *alertImg = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 40/2.0f, 30/2.0f)];

    }
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void) addAlert: (MenuAlertsImageType) alertType
{
    
//    [_list addObject: [NSNumber numberWithInt: alertType] ];
    UIImage *alertImg;
    
//    if ( [_list count] > 0 )
//    {
//        _listPtr = [_list first];
//    }
    
    
    switch ( (MenuAlertsImageType)alertType )
    {
        case kMenuAlertsImageAlerts:

            alertImg = [UIImage imageNamed:@"system_status_alert.png"];
            break;
        
        case kMenuAlertsImageAdvisories:
            
            alertImg = [UIImage imageNamed:@"system_status_advisory.png"];
            break;
        
        case kMenuAlertsImageDetours:
            
            alertImg = [UIImage imageNamed:@"system_status_detour.png"];
            break;
            
        default:
            break;
    }
    
    
    // This is not the optimal method for handling things.  It will create n UIImageView, whereas the optimal method requires
    //   only 2, the image that's at zero alpha and the image that's at 1.
    if ( alertImg != nil )
    {
        UIImageView *alertImageView = [[UIImageView alloc] initWithFrame: CGRectMake(23, -2, 40/2.0f, 30/2.0f) ];
        [alertImageView setImage: alertImg];
        
        if ( [_imageViewArray count] == 0 )
            [alertImageView setAlpha: 1.0f];
        else
            [alertImageView setAlpha:0.0f];
        
        [alertImageView setTag: alertType];
        
//        [_mainImageView addSubview: alertImageView];
        [_baseButton addSubview: alertImageView];
        
        [_imageViewArray addObject: alertImageView];
        NSLog(@"AlertImageView: %@", alertImageView);
    }
    
    [self startLoop];
    
}


-(void) removeAlert: (MenuAlertsImageType) alertType
{
    

    UIImageView *viewToRemove;
    NSInteger count = 0;
    for (UIImageView *iView in _imageViewArray)
    {
        if (iView.tag == alertType)
        {
            viewToRemove = iView;
            break;
        }
        count++;
    }

    if ( viewToRemove == nil )
        return;  // Nothing to remove
    
    // If the array is nil, initialize it
    if ( _alertsToRemove == nil )
        _alertsToRemove = [[NSMutableArray alloc] init];
    
    // Ensure the view isn't already slated to be removed
    if ( ![_alertsToRemove containsObject: viewToRemove] )
        [_alertsToRemove addObject: viewToRemove];
    
    return;
    
//    [self stopLoop];
//    
//    UIImageView *viewToRemove;
//    NSInteger count = 0;
//    for (UIImageView *iView in _imageViewArray)
//    {
//        if (iView.tag == alertType)
//        {
//            viewToRemove = iView;
//            break;
//        }
//        count++;
//    }
    
    
    // If an alert is being removed that is currently being animated, there is a slight visual glitch where both alerts are visible briefly
    // TODO: Detect which alert is being animated and wait until its done before removing.
    
//    if ( count == _index )
//    {
        // If they're the same, we're about to remove
//        NSLog(@"Alpha: %4.2f", viewToRemove.alpha);
//        _index--;
//        if ( _index < 0 )
//            _index = 0;
//    }
    
    
//    [UIView animateWithDuration: (_duration * viewToRemove.alpha)  // _duration is a function of how much alpha it has
//                          delay: 0.0f
//                        options: UIViewAnimationCurveEaseInOut
//                     animations:^{
//                         [viewToRemove setAlpha:0.0f];
//                     }
//                     completion:^(BOOL finished) {
//                         NSLog(@"removeAlert - Animation complete");
//                         [viewToRemove removeFromSuperview];
//                         [self startLoop];
//                     }];

    
//    [viewToRemove setAlpha:0.0f];
//    [_imageViewArray removeObject: viewToRemove];
//    
//    [self startLoop];
    
}



-(void) removeAllAlerts
{
    [self stopLoop];
    
    for (UIImageView *thisView in _imageViewArray)
    {
        [thisView removeFromSuperview];
    }

    [_imageViewArray removeAllObjects];
    
}

-(void) incrementIndex
{
    
    if (_index < ([_imageViewArray count] -1 ) )
        _index++;
    else
        _index = 0;
    
}


-(void) nextLoop
{
    
    UIImageView *imageA;
    UIImageView *imageB;
    
    // Any alerts to be removed?
    if ( _alertsToRemove )
    {
        // Yes!
        
        for (UIImageView *alertView in _alertsToRemove)
        {
            [alertView setAlpha:0.0f];  // Make the alert invisible
        }
        [_imageViewArray removeObjectsInArray:_alertsToRemove];
    }
    
    NSInteger arraySize = [_imageViewArray count];

    // Checks
    if ( arraySize == 0 )
        return;  // There's nothing to loop through
    else if ( arraySize == 1 )
    {
        // Only one image, always keep this active
        imageA = (UIImageView*)[_imageViewArray objectAtIndex:0];
        [imageA setAlpha:1.0f];
        return;
    }
    
    
    // Multiple images, cycle through each one
    imageA = [_imageViewArray objectAtIndex:_index];
    if ( imageA.alpha >= 0.999f )
    {
        
        [self incrementIndex];
        imageB = [_imageViewArray objectAtIndex:_index];
        
    }
    else
    {
        imageB = imageA;
        imageA = nil;
    }
    
    
//    NSLog(@"Next Loop");
    
     [UIView animateWithDuration: _duration
                           delay: _delay
                         options: UIViewAnimationOptionCurveEaseInOut
                      animations:^{
                          [imageA setAlpha:0.0f];
                          [imageB setAlpha:1.0f];
                      }
                      completion:^(BOOL finished) {
//                          NSLog(@"Animation complete");
                      }];
    
    // Any alerts to be removed?
    
    
    
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


-(void) setBaseImage: (UIImage*) image
{
//    [_mainImageView setImage: image];
    [_baseButton setImage:image forState:UIControlStateNormal];
}


-(void) addTarget:(id) target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{

    [_baseButton addTarget:target action:action forControlEvents:controlEvents];
    
}



@end
