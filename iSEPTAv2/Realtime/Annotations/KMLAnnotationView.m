//
//  KMLAnnotationView.m
//  iSEPTA
//
//  Created by septa on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import "KMLAnnotationView.h"

@implementation KMLAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if ( self )
    {
        KMLAnnotation *annotation = self.annotation;
        switch (annotation.type)
        {
            case kKMLTrolleyBlue:
                self.image = [UIImage imageNamed:@"transitView-Trolley-Blue.png"];
                break;
            case kKMLTrolleyRed:
                self.image = [UIImage imageNamed:@"transitView-Trolley-Red.png"];
                break;
            case kKMLBusBlue:
                self.image = [UIImage imageNamed:@"transitView-Bus-Blue.png"];
                break;
            case kKMLBusRed:
                self.image = [UIImage imageNamed:@"transitView-Bus-Red.png"];
                break;
            case kKMLTrainBlue:
                self.image = [UIImage imageNamed:@"trainView-RRL-Blue.png"];
                break;
            case kKMLTrainRed:
                self.image = [UIImage imageNamed:@"trainView-RRL-Red.png"];
                break;
                
            default:
                self.image = nil;
                break;
        }
    }
    return self;
    
}

@end
