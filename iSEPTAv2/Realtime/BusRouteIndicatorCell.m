//
//  BusRouteIndicatorCell.m
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "BusRouteIndicatorCell.h"

@implementation BusRouteIndicatorCell
{
    NSMutableArray *_buttonPtr;
    int numButtons;
    int _buttonLimit;
    int _oldLimit;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}


-(id) initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if ( self )
    {
        if ( UIDeviceOrientationIsLandscape( [UIDevice currentDevice].orientation ) )
        {
            _buttonLimit = 13;
        }
        else
        {
            _buttonLimit = 7;
        }
    }
    
    return self;
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)layoutSubviews
{
    
    [super layoutSubviews];
    
    _oldLimit = _buttonLimit;
    
    //    [UIApplication sharedApplication] statusBarOrientation  -- Been using this for orientation lately, hmmmm....
    if ( UIDeviceOrientationIsLandscape( [UIDevice currentDevice].orientation ) )
    {
        _buttonLimit = 13;
    }
    else
    {
        _buttonLimit = 7;
    }

//    NSLog(@"BRIC: layoutSubviews");
    
}



-(void) addRouteInfo:(BasicRouteObject *)routeInfo
{
    
    // 8 route "buttons" are the limit for Portrait mode.
    
    [self.lblDistance setText: [NSString stringWithFormat:@"%3.2f",[routeInfo.distance floatValue] ] ];
    [self.lblStopName setText:routeInfo.stop_name];

    
    if ( _buttonPtr == nil )
    {
        _buttonPtr = [[NSMutableArray alloc] init];
        numButtons = 0;
    }
    
    
    for (UIButton *btn in _buttonPtr)
    {
        [btn removeFromSuperview];
        numButtons = 0;
    }
    
    
    
    int x = 50;
    int y = 22;
    
    int width = 40;
    int height = 18;
    
    int padding = 1;
    
    float cornerRadius = 5.0f;
    float fontSize = 13.0f;
    
    for ( RouteDetailsObject* dObj in routeInfo.routeData )
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        
//        [button setTitle:[NSString stringWithFormat:@"%@%@", dObj.route_short_name, dObj.Direction] forState:UIControlStateNormal];
        [button setTitle: dObj.route_short_name forState:UIControlStateNormal];
        [button setUserInteractionEnabled:NO];  // Disable button clicking
 
        [button setBackgroundColor: [self colorFor:dObj] ];
        
        [button.layer setCornerRadius: cornerRadius];
 
        
        // Configure button text
        [button.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:fontSize]];
//        [button.titleLabel setFont:[UIFont boldSystemFontOfSize: fontSize] ];
        [button.titleLabel setTextColor:[UIColor whiteColor] ];
        
        [self addSubview: button];
        [_buttonPtr addObject:button];
        
        x += width + padding;

        numButtons++;
        if ( numButtons == _buttonLimit && [routeInfo.routeData count] != numButtons )
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
            [button setTitle:@"..." forState:UIControlStateNormal];
            [button setUserInteractionEnabled:YES];
            [button addTarget:self action:@selector(showMoreButtons:) forControlEvents:UIControlEventTouchDown];
            
            [button setBackgroundColor: [UIColor blackColor] ];
            [button.layer setCornerRadius: cornerRadius];
            
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize: fontSize] ];
            [button.titleLabel setTextColor: [UIColor whiteColor] ];
            
            [self addSubview: button];
            [_buttonPtr addObject: button];
            
            break;
        }
        
    }
    
//    NSLog(@"%@, count %d", routeInfo.stop_name, numButtons);
    
}


-(void) showMoreButtons:(UIButton*) sender
{
//    NSLog(@"Show More Buttons"); 
}

/*
 
 typedef NS_ENUM(NSInteger, BusRoutesDefaultCellImageType)  // According to the GTFS guidelines
 {
 kBusRoutesDefaultCellImageTrolley = 0,
 kBusRoutesDefaultCellImageSubway  = 1,
 kBusRoutesDefaultCellImageRail    = 2,
 kBusRoutesDefaultCellImageBus     = 3,
 
 */

-(UIColor*) colorFor:(RouteDetailsObject*) dObj
{
    
    // TODO: Do not hard code this shit.  Create a GTFS Header file with all the important bits.
    
    switch ([dObj.route_type intValue])
    {
        case kRouteTypeTrolley:  // Trolley: NHSL and the number routes
            
            if ( [dObj.route_short_name isEqualToString:@"NHSL"] )
                return [UIColor colorForRouteType:kSEPTATypeNHSL];
            else
                return [UIColor colorForRouteType:kSEPTATypeTrolley];
            
            break;
            
        case kRouteTypeBus:  // All numbers and letters routes (except NHSL, BSS and MFL)
            
            if ( [dObj.route_short_name isEqualToString:@"MFO"] )
                return [UIColor colorForRouteType:kSEPTATypeMFL];
            else if ( [dObj.route_short_name isEqualToString:@"BSO"] )
                return [UIColor colorForRouteType:kSEPTATypeBSL];
            else
                return [UIColor colorForRouteType:kSEPTATypeBus];
            
            break;
            
        case kRouteTypeRail:  // Regional Rail
            return [UIColor colorForRouteType:kSEPTATypeRail];
            break;
            
        case kRouteTypeSubway:  // BSS and MFL
            if ( [dObj.route_short_name isEqualToString:@"BSS"] )
                return [UIColor colorForRouteType:kSEPTATypeBSL];
            else if ( [dObj.route_short_name isEqualToString:@"MFL"] )
                return [UIColor colorForRouteType:kSEPTATypeMFL];
            
            return [UIColor blackColor];
            
            break;
            
            
        default:
                return [UIColor blackColor];
            break;
    }
    

}

@end
