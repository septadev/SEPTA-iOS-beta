//
//  CustomerService.m
//  iSEPTA
//
//  Created by Justin Brathwaite on 4/13/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "CustomerServiceViewController.h"
//#import "facebook.h"
#import "AppDelegate.h"



@interface CustomerServiceViewController ()

@end

@implementation CustomerServiceViewController

//facebook *CSviewcontroller;

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
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
     self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"splashblank.png"]];
    [self createMenu];

	// Do any additional setup after loading the view.
    
    float tabHeight = self.tabBarController.tabBar.frame.size.height;
    float navHeight = self.navigationController.navigationBar.frame.size.height;
    float viewHeight = self.view.frame.size.height;
    float scrollHeight = scrollView.frame.size.height;
    [scrollView setScrollIndicatorInsets: UIEdgeInsetsMake(0, 0, scrollHeight-viewHeight+tabHeight+navHeight, 0)]; // top, left, bottom, right
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)createMenu
{
   // UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(320, 600);
    scrollView.showsVerticalScrollIndicator = YES;
    //[self.view addSubview:scrollView];
    //CGRect frameCallButton = CGRectMake(0, 10.0, 195, 50.0);
   // CallButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [CallButton addTarget:self 
                  action:@selector(goButtonPressed:)
        forControlEvents:UIControlEventTouchDown];
    //CallButton.frame = frameCallButton;
    //[CallButton setTitle:@"Call Customer Service" forState:UIControlStateNormal];
    //[scrollView addSubview:CallButton];
    
   // CGRect framefaceBookButton = CGRectMake(0, 75, 195, 50.0);
    //faceBookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [faceBookButton addTarget:self 
                   action:@selector(goButtonPressed:)
         forControlEvents:UIControlEventTouchDown];
    //faceBookButton.frame = framefaceBookButton;
    //[faceBookButton setTitle:@"FaceBook" forState:UIControlStateNormal];
    //[scrollView addSubview:faceBookButton];
    
    //CGRect frametwitterButton = CGRectMake(0, 135, 195, 50.0);
    //twitterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twitterButton addTarget:self 
                       action:@selector(goButtonPressed:)
             forControlEvents:UIControlEventTouchDown];
    //twitterButton.frame = frametwitterButton;
    //[twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
    //[scrollView addSubview:twitterButton];
    
    //CGRect frameYouTubeButton = CGRectMake(0, 200, 195, 50.0);
    ///YouTubeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [YouTubeButton addTarget:self 
//                      action:@selector(goButtonPressed:)
//            forControlEvents:UIControlEventTouchDown];
    //YouTubeButton.frame = frameYouTubeButton;
    //[YouTubeButton setTitle:@"YouTube" forState:UIControlStateNormal];
    //[scrollView addSubview:YouTubeButton];
    
   // CGRect frameCommentFormButton = CGRectMake(0, 265, 195, 50.0);
    //CommentFormButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    // Uncomment to allow the button to response to a touch down event
    [CommentFormButton addTarget:self 
                      action:@selector(goButtonPressed:)
            forControlEvents:UIControlEventTouchDown];
    
    
    //CommentFormButton.frame = frameCommentFormButton;
    //[CommentFormButton setTitle:@"Comments" forState:UIControlStateNormal];
    //[scrollView addSubview:CommentFormButton];
    
}
-(void) goButtonPressed:(id)sender
{
    
//    CSviewcontroller=[[facebook alloc]initWithNibName:nil bundle:nil];
//    AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(sender ==CallButton)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call SEPTA Customer Service" message:@"Do You wish to call Customer Service" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
        
    }
    else if (sender ==faceBookButton)
    {
//        CSviewcontroller.title =@"SEPTA on FaceBook";
//        appDelegate.busdata.webaddress = @"FaceBook";
//         [self.navigationController pushViewController:CSviewcontroller animated:YES];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/174505962565714"] ];

    }
    else if (sender ==twitterButton)
    {
//        CSviewcontroller.title =@"SEPTA on Twitter";
//         appDelegate.busdata.webaddress = @"Twitter";
//         [self.navigationController pushViewController:CSviewcontroller animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=@SEPTA_SOCIAL"] ];
    }
//    else if (sender ==YouTubeButton)
//    {
//        CSviewcontroller.title =@"SEPTA on YouTube";
//        appDelegate.busdata.webaddress = @"YouTube";
//        [self.navigationController pushViewController:CSviewcontroller animated:YES];
//    }
    else if (sender == CommentFormButton)
    {
//
//        CommentForm *commentForm = [[CommentForm alloc] init] ;
//        [self presentModalViewController:commentForm animated:YES];
        
//        CommentFormViewController *commentFormVC = [[CommentFormViewController alloc] init];
//        [self presentViewController:commentFormVC animated:YES completion:^{ NSLog(@"CSVC - presented CommentFormVC"); }];

        [self createForm];
        
    }
    
}


-(void) createForm
{
    
//    QRootElement *root = [[QRootElement alloc] init];
//    [root setTitle:@"Comment Form"];
//    [root setControllerName:@"CommentQuickViewController"];
//    [root setGrouped:YES];
//    
//////    QSection *spacer = [[QSection alloc] init];
//////    QSection *spacer2 = [[QSection alloc] init];
//////
//////    QLabelElement *blank = [[QLabelElement alloc] init];
//////    [blank setHidden:YES];
//////    
//////    [spacer addElement:blank];
//////    [root addSection: spacer];
//////    [root addSection: spacer2];
//    
//    QSection *personalInfoSection = [[QSection alloc] init];
//    
//    QEntryElement *name  = [[QEntryElement alloc] initWithTitle:@"Name" Value:nil Placeholder:@"required"];
//    QEntryElement *phone = [[QEntryElement alloc] initWithTitle:@"Phone" Value:nil Placeholder:@"required"];
//    QEntryElement *email = [[QEntryElement alloc] initWithTitle:@"Email" Value:nil Placeholder:@"required"];
//        
//    
//    [name setKey:@"name"];
//    [phone setKey:@"phone"];
//    [email setKey:@"email"];
//    
//    [personalInfoSection addElement:name];
//    [personalInfoSection addElement:phone];
//    [personalInfoSection addElement:email];
//    
//    [root addSection:personalInfoSection];
//    
//
//    // --==  NEXT SECTION:  INCIDIENT/TRAVEL  ==--
//    
//    // Change in QDateTimeInlineElement init method requires the code to be modified below
////    QSection *dateTimeSection = [[QSection alloc] initWithTitle:@"Incident/Travel"];
////    
////    NSDate *oneTimeToRuleThemAll = [NSDate date];
////    QDateTimeInlineElement *time = [[QDateTimeInlineElement alloc] initWithTitle:@"Time" date: oneTimeToRuleThemAll ];
////    [time setMode:UIDatePickerModeTime ];
////
////    QDateTimeInlineElement *date = [[QDateTimeInlineElement alloc] initWithTitle:@"Incident/Travel" date: oneTimeToRuleThemAll ];
////    [date setMode:UIDatePickerModeDate ];
////    date.key = @"incidentDate";
////
////    [dateTimeSection addElement:date];
////    [dateTimeSection addElement:time];
////    
////    [root addSection: dateTimeSection];
//    
//    
//    // --==  NEXT SECTION:  INFORMATION  ==--
//    QSection *information = [[QSection alloc] init];
//    
//    
//    QEntryElement *boardingLocation  = [[QEntryElement alloc] initWithTitle:@"Location" Value:nil Placeholder:@"Boarding Location"];
//    boardingLocation.key = @"boardingLocation";
//    QEntryElement *finalDestination = [[QEntryElement alloc] initWithTitle:@"Destination" Value:nil Placeholder:@"Final Destination"];
//    finalDestination.key = @"finalDestination";
//    
//    QEntryElement *route = [[QEntryElement alloc] initWithTitle:@"Route" Value:nil Placeholder:@"Route Name"];
//    route.key = @"route";
//    
//    QEntryElement *vehicle = [[QEntryElement alloc] initWithTitle:@"Vehicle #" Value:nil Placeholder:@"Vehicle #"];
//    vehicle.key = @"vehicle";
//    
//    QEntryElement *block   = [[QEntryElement alloc] initWithTitle:@"Block #" Value:nil Placeholder:@"Block #"];
//    block.key = @"block";
//    
//    QEntryElement *direction = [[QEntryElement alloc] initWithTitle:@"Direction" Value:nil Placeholder:@"Direction of Travel"];
//    direction.key = @"direction";
//    
////    [information addElement:date];
//    [information addElement:boardingLocation];
//    [information addElement:finalDestination];
//    [information addElement:route];
//    
//    [information addElement:vehicle];
//    [information addElement:block];
//    [information addElement:direction];
//    
//    [root addSection:information];
//    
//    NSArray *radioArray = [[NSArray alloc] initWithObjects:@"Compliment", @"Concern", @"Inquiry", @"Suggestion", @"Website", nil];
//    
//    QSection *commentSection = [[QSection alloc] initWithTitle:@"Please choose your comment type"];
//    QRadioElement *radioElement = [[QRadioElement alloc] initWithItems:radioArray selected:0 title:nil];
//    
//    [commentSection addElement: radioElement];
//    
//    [root addSection: commentSection];
//    
//    
//    QSection *employeeSection = [[QSection alloc] initWithTitle:@"If the reason for contact involves SEPTA personnel, please provide name, employee number or give a brief physical description"];
//    QMultilineElement *employeeMulti = [QMultilineElement new];
//    [employeeMulti setTitle:@"Description"];
//    
//    [employeeSection addElement: employeeMulti];
//    [root addSection: employeeSection];
//    
//    
//    QSection *detailsSection = [[QSection alloc] initWithTitle:@"Details:"];
//    QMultilineElement *detailsMulti = [QMultilineElement new];
//    [detailsMulti setTitle:@"Details"];
//    
//    [detailsSection addElement: detailsMulti];
//    [root addSection: detailsSection];
//    
//    QSection *btnSection = [[QSection alloc] init];
//    QButtonElement *button = [[QButtonElement alloc] initWithTitle:@"Submit"];
//    
//    [btnSection addElement:button];
//    [root addSection:btnSection];
//    
//    button.onSelected = ^{
//        
//        // Required fields
//        if ( [name textValue] != nil && [phone textValue] != nil && [email textValue] != nil )
//        {
//            NSString *filteredName;
//            NSString *filteredPhone;
//            NSString *filteredEmail;
//            NSString *filteredDate;
//            NSString *filteredLocation;
//            NSString *filteredRoute;
//            NSString *filteredVehicle;
//            NSString *filteredBlock;
//            NSString *filteredTime;
//            NSString *filteredDestination;
//            NSString *filteredDirection;
//            NSString *filteredCommentType;
//            NSString *filteredEmployee;  // First textarea
//            NSString *filteredComments;  // Details (second) textarea
//            
//            filteredName = [[name textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            filteredPhone = [[phone textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            filteredEmail = [[email textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
//            
//            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
//            [timeFormatter setDateFormat:@"HH:mm:ss"];
//            
////            filteredDate = [[dateFormatter stringFromDate:[date dateValue] ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            if ( [boardingLocation textValue] != nil )
//                filteredLocation = [[boardingLocation textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            else
//                filteredLocation = @"";
//            
//            if ( [route textValue] != nil )
//                filteredRoute = [[route textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            else
//                filteredRoute = @"";
//            
//            if ( [vehicle textValue] != nil )
//                filteredVehicle = [[vehicle textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            else
//                filteredVehicle = @"";
//            
//            if ( [block textValue] != nil )
//                filteredBlock = [[block textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            else
//                filteredBlock = @"";
//            
////            filteredTime = [[timeFormatter stringFromDate:[date dateValue] ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            if ( [finalDestination textValue] != nil )
//                filteredDestination = [[finalDestination textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            else
//                filteredDestination = @"";
//            
//            if ( [direction textValue] != nil )
//                filteredDirection = [[direction textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            else
//                filteredDirection = @"";
//            
//            filteredCommentType = [[radioArray objectAtIndex:[radioElement selected]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            if ( [employeeMulti textValue] != nil )
//                filteredEmployee = [[employeeMulti textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            else
//                filteredEmployee = @"";
//            
//            if ( [detailsMulti textValue] != nil )
//            {
////                filteredComments = [filteredComments stringByAppendingFormat:@"\nSent from iPhone/iPad"];
//                filteredComments = [[detailsMulti textValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            }
//            else
//                filteredComments = @"";
//            
////            filteredComments = [@"This is a test of the iPhone SETPA App.  Please disregard." stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            
//            //        NSString *urlString = [NSString stringWithFormat:@"http://www.septa.org/cs/comment/FormMail.cgi?recipient=cservice%%40septa.org&wl_tp=Empolyee%%2CComments&subject=Inquiry+from+www.septa.org&required=Name%%2Cemail%%2Cphone&Name=%@&phone=%@&email=%@&Incident+Date=%@&Boarding+Location=%@&route=%@&vehicle=%@&block=%@&Time+of+Incident=%@&Final+Destination=%@&Direction+of+Travel=%@&Comment=%@&Employee=%@&Comments=%@", filteredName, filteredPhone, filteredEmail, filteredDate, filteredLocation, filteredRoute, filteredVehicle, filteredBlock, filteredTime, filteredDestination, filteredDirection, filteredCommentType, filteredEmployee, filteredComments];
//            
//            NSString *urlString = @"http://www.septa.org/cs/comment/FormMail.cgi";
//            
//            // Removed the ? from the beginning of POST string
//            NSString *postString = [NSString stringWithFormat:@"recipient=cservice%%40septa.org&wl_tp=Empolyee%%2CComments&subject=Inquiry+from+www.septa.org&required=Name%%2Cemail%%2Cphone&Name=%@&phone=%@&email=%@&Incident+Date=%@&Boarding+Location=%@&route=%@&vehicle=%@&block=%@&Time+of+Incident=%@&Final+Destination=%@&Direction+of+Travel=%@&Comment=%@&Employee=%@&Comments=%@", filteredName, filteredPhone, filteredEmail, filteredDate, filteredLocation, filteredRoute, filteredVehicle, filteredBlock, filteredTime, filteredDestination, filteredDirection, filteredCommentType, filteredEmployee, filteredComments];
//            
//            NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
//            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString] ];
//            
//            
//            
////            NSString *newString = [NSString stringWithFormat:@"%@%@", urlString, postString];
////            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newString]];
//
//            [request setHTTPMethod:@"POST"];
//            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//            [request setHTTPBody:postData];
//            
////            [request setValue: [NSString stringWithFormat:@"%d", [postString length]] forHTTPHeaderField:@"Content-length"];
//            
////            [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
//            
//            //        id result = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//            
//            NSHTTPURLResponse *urlResponse;
//            NSError *error;
//            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//            
//            int statusCode = [urlResponse statusCode];
//            int errorCode = error.code;
//            
//            NSLog(@"urlString : %@", urlString);
//            NSLog(@"postString: %@", postString);
////            NSLog(@"newString : %@", newString);
//            
//            NSLog(@"status: %d, errorCode: %d", statusCode, errorCode);
//            NSString *dataStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//            NSString *content = [NSString stringWithUTF8String:[responseData bytes] ];
//            NSLog(@"response: %@", dataStr);
//            NSLog(@"content : %@", content);
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:@"Your comment has been submitted." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//            
////            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered text" message:urlString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
////            [alert show];
//            
//            [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"CSVC - Dismissed Customer Form"); }];
//            
//       
//        }  // if ( [name textValue] != nil && [phone textValue] != nil && [email textValue] != nil )
//        else
//        {
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold On!" message:@"Please fill in all required fields before submitting comments." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//            
//        }
//        
//    };
//    
//    
//    CommentQuickViewController *quickController = (CommentQuickViewController*) [[CommentQuickViewController alloc] initWithRoot:root];
//    [[self navigationController] pushViewController:quickController animated:YES];
    
    //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:quickController];
    //    [self presentModalViewController:nav animated:YES];
    //    [self presentViewController:nav animated:YES completion:^{ NSLog(@"CSVC - Root Elements Loaded"); }];

    
////    CustomerServiceViewController *csvc = (CustomerServiceViewController*)[QuickDialogController controllerForRoot:root];
//    UINavigationController *navigation = [QuickDialogController controllerWithNavigationForRoot:root];
////    UIViewController *navigation = [QuickDialogController controllerForRoot:root];
    
////    CGRect frameToolBar = CGRectMake(0, 0.0, 195, 50.0);
////    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:frameToolBar];
////    toolBar.barStyle = UIBarStyleBlackOpaque;
////    [toolBar sizeToFit];
////    
////    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
////                                                                     style:UIBarButtonItemStyleDone target:self action:@selector(goButtonPressed:)];
////    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
////    
////    UIBarButtonItem *SendButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
////                                                                   style:UIBarButtonItemStyleDone target:self action:@selector(goButtonPressed:)];
////    CancelButton.tintColor= [UIColor blackColor];
////    SendButton.tintColor= [UIColor blackColor];
////    toolBar.items = [NSArray arrayWithObjects:CancelButton,flexibleSpace,SendButton, nil ];
//    
////    [navigation setToolbarHidden:NO];
////    [navigation setToolbarItems: [NSArray arrayWithObjects:CancelButton,flexibleSpace,SendButton, nil ] ];
//    
    
//    [self presentViewController:navigation animated:YES completion:^{ NSLog(@"CSVC - Finished Presenting View Controller"); }];

//    [self presentModalViewController:navigation animated:YES];
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {
        
        NSURL *URL = [NSURL URLWithString:@"tel://215-580-7853"];
        [[UIApplication sharedApplication] openURL:URL];
    }
    
}

#pragma mark -
#pragma mark Segues

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString:@"CommentFormSegue" ] )
    {
        NSLog(@"Comment Form Segue is good.");
    }
    
}


@end
