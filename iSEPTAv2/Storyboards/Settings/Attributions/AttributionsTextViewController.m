//
//  AttributionsTextViewController.m
//  iSEPTA
//
//  Created by septa on 9/13/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "AttributionsTextViewController.h"

@interface AttributionsTextViewController ()

@end

@implementation AttributionsTextViewController

@synthesize data = _data;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [self loadLicense];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
    
    [self setTxtViewAttribution:nil];
    [super viewDidUnload];
    
}



-(void) loadLicense
{
    
//    NSError *error;
//    NSString *licenseText = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@License.txt", _data.library]
//                                                            encoding:NSUTF8StringEncoding
//                                                               error: &error];
    
    
    if ( _data != nil )
    {
        [self.txtViewAttribution setText: _data.license];
    }
    else
    {
        [self.txtViewAttribution setText: @"No license file found"];
    }

    
    
}



@end
