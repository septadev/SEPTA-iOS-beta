//
//  SlidingAlertViewController.m
//  iSEPTA
//
//  Created by septa on 6/12/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "SlidingAlertViewController.h"

@interface SlidingAlertViewController ()

@end

@implementation SlidingAlertViewController

@synthesize slidingAlert = _slidingAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"Rotate All the Views!");

    CGFloat sWidth  = [UIScreen mainScreen].bounds.size.width;
    CGFloat sHeight = [UIScreen mainScreen].bounds.size.height;
    
    int padding = 8;
    int iconWidth = 96;
    
    int aWidth = 0;
    int aHeight = 0;
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
    {
//        [self.slidingAlert rotate:toInterfaceOrientation];

        // Height is now the Width; Width is now the Height
        
        int wastedSpace = 44 + 40 + 12;
        
        int x = padding * 4 + iconWidth * 3;
        int aWidth = sHeight - x - 8;
        int aHeight = sWidth - wastedSpace - padding*2;
        
        [self.slidingAlert setFrame:CGRectMake(x, 8, aWidth, aHeight)];
        [self.slidingAlert setNeedsDisplay];
    }
    else if ( toInterfaceOrientation == UIInterfaceOrientationPortrait )
    {
//        [self.slidingAlert rotate:toInterfaceOrientation];
        [self.slidingAlert setFrame:CGRectMake(8, 212, 304, 149)];
        [self.slidingAlert setNeedsDisplay];
    }
    
    
    
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
    {
        NSLog(@"Landscape");
    }
    else if ( toInterfaceOrientation == UIInterfaceOrientationMaskPortrait )
    {
        NSLog(@"Portrait");
    }
    else
    {
        NSLog(@"No change");
    }
    
    return YES;
    
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.view setBackgroundColor: backgroundColor];
    
    CGRect viewRect = CGRectMake(8, 212, 304, 149);
    self.slidingAlert = [[SlidingAlertView alloc] initWithFrame:viewRect];
    [self.view addSubview: self.slidingAlert];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
