//
//  FirstViewController.m
//  iSEPTAv2
//
//  Created by Justin Brathwaite on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RealtimeViewController.h"

#import "NextToArriveViewController.h"
#import "TrainViewViewController.h"
#import "TransitViewTableController.h"

#import "NewTrainViewViewController.h"

//#import "AppDelegate.h"

@interface RealtimeViewController ()

@end

@implementation RealtimeViewController
{
    CGRect boundsNTA;
    CGRect frameNTA;
}

- (void)viewDidLoad
{
        
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"splashblank.png"]];
//    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bkg.png"]];

//    [scrollview setScrollEnabled:YES];
    [scrollview setContentSize: CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    
//    [scrollview setShowsVerticalScrollIndicator:YES];
    
//    [self.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
//    [[btnNextToArrive imageView] setContentMode: UIViewContentModeScaleAspectFit];
    
//    [self.view setAutoresizesSubviews:YES];
//    [btnNextToArrive setAutoresizingMask: UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    boundsNTA = btnNextToArrive.bounds;
//    frameNTA = image.frame;
    
//    image.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
//    image.contentMode = UIViewContentModeScaleAspectFit;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    float tabHeight = self.tabBarController.tabBar.frame.size.height;
    float navHeight = self.navigationController.navigationBar.frame.size.height;
    float viewHeight = self.view.frame.size.height;
    float scrollHeight = scrollview.frame.size.height;
    [scrollview setScrollIndicatorInsets: UIEdgeInsetsMake(0, 0, scrollHeight-viewHeight+tabHeight+navHeight, 0)]; // top, left, bottom, right
    
    NSLog(@"RVC - tabHeight: %6.2f, navHeight: %6.2f, viewHeight: %6.2f, scrollHeight: %6.2f", tabHeight, navHeight, viewHeight, scrollHeight);
    NSLog(@"RVC - view frame: %@", NSStringFromCGRect(self.view.frame));
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    NSLog(@"RVC - shouldAutorotate?");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
        return NO;
    
}


//-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//
////    NSLog(@"RVC - didRotateFromInterface");
////    [btnNextToArrive sizeThatFits:CGSizeMake(self.view.frame.size.width, btnNextToArrive.frame.size.height)];
//    
//    if ( fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
//    {
////        btnNextToArrive.frame = CGRectMake(23,5,self.view.frame.size.width,30);
////        btnNextToArrive.imageView.frame = CGRectMake(55, 0, 480, 30);
////        NSLog(@"");
//    }
//    else
//    {
////        btnNextToArrive.frame = CGRectMake(23,5,100,55);
////        btnNextToArrive.imageView.frame = CGRectMake(3, 0, 100, 55);
//    }
//
//}


-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    NSLog(@"RVC - willAnimateRoutation... YES!");
////    [btnNextToArrive sizeToFit];s
//}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString:@"NextToArriveSegue"] )
    {
//        NextToArriveViewController *realtimeVC = [segue destinationViewController];
    }
    else if ( [[segue identifier] isEqualToString:@"TransitViewSegue"] )
    {
//        TransitViewTableController *realtimeVC = [segue destinationViewController];
    }
    else if ( [[segue identifier] isEqualToString:@"TrainViewSegue"] )
    {
        NewTrainViewViewController *realtimeVC = [segue destinationViewController];
        [realtimeVC setTravelMode:@"Rail"];
    }
    
}

@end
