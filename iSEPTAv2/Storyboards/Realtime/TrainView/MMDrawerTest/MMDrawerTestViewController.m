//
//  MMDrawerTestViewController.m
//  iSEPTA
//
//  Created by septa on 10/10/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MMDrawerTestViewController.h"

@interface MMDrawerTestViewController ()

@end

@implementation MMDrawerTestViewController
{
//    MMDrawerController *_drawerController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id) init
{
    
    self = [super init];
    if ( self != nil )
    {
//        UIViewController * leftDrawer = [[UIViewController alloc] init];
        UIViewController * center = [[UIViewController alloc] init];
        UIViewController * rightDrawer = [[UIViewController alloc] init];
        
//        [leftDrawer setTitle:@"Left"];
//        [leftDrawer.view setBackgroundColor:[UIColor whiteColor] ];
        
        [center setTitle:@"Center"];
        [center.view setBackgroundColor:[UIColor blueColor] ];
        
        [rightDrawer setTitle:@"Right"];
        [rightDrawer.view setBackgroundColor: [UIColor redColor] ];
        
//        [self setCenterViewController:center];
//        [self setRightDrawerViewController: rightDrawer];
//        
//        
//        [self setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
//            BOOL shouldRecognizeTouch = NO;
//            
//            return shouldRecognizeTouch;
//        }];
        
    }
    return self;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupRightMenuButton];
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}


-(void) viewWillDisappear:(BOOL)animated
{
    
    
    [super viewWillDisappear: animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setupRightMenuButton
{
    
//    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
//    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
    
}

-(void)rightDrawerButtonPress:(id)sender
{
//    [self toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}



@end
