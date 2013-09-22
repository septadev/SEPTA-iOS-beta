//
//  CommentQuickViewController.m
//  iSEPTA
//
//  Created by septa on 2/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CommentQuickViewController.h"

@interface CommentQuickViewController ()

@end

@implementation CommentQuickViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"CQVC -(void) viewDidLoad");

//    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
//    [[self navigationItem] setBackBarButtonItem: backBarItem];
    
//    NSLog(@"CQVC - Back title: %@", [[[self navigationItem] backBarButtonItem] title] );
//    [[self navigationItem] setRightBarButtonItem:backBarItem];
    
}

-(void) cancel: (id) sender
{
    NSLog(@"CQVC -(void) cancel");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}


- (void)displayViewControllerForRoot:(QRootElement *)element {
    
    NSLog(@"CQVC - displayViewControllerForRoot");
    QuickDialogController *newController = [QuickDialogController controllerForRoot:element];
//    if (self.splitViewController!=nil){
//        UINavigationController * navController = [self.splitViewController.viewControllers objectAtIndex:1];
//        
//        for (QSection *section in self.root.sections) {
//            for (QElement *current in section.elements){
//                if (current==element) {
//                    self.splitViewController.viewControllers = @[[self.splitViewController.viewControllers objectAtIndex:0], [[UINavigationController alloc] initWithRootViewController:newController]];
//                    return;
//                }
//            }
//        }
//        [navController pushViewController:newController animated:YES];
//    } else {
        [super displayViewController:newController];
//    }
    
}


@end
