//
//  ConnectViewController.m
//  iSEPTA
//
//  Created by Administrator on 8/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ConnectViewController.h"

@interface ConnectViewController ()

@end

@implementation ConnectViewController
{
    UIImage *attachmentImage;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // --== Background Image  ==--
//    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
//    [self.tableView setBackgroundView: bgImageView];

    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.tableView setBackgroundColor: backgroundColor];

    
    UIImage *logo = [UIImage imageNamed:@"SEPTA_logo.png"];
    
    SEPTATitle *newView = [[SEPTATitle alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height) andWithTitle:@"Connect"];
    [newView setImage: logo];
    
    [self.navigationItem setTitleView: newView];
    [self.navigationItem.titleView setNeedsDisplay];
    
    
//    NSLog(@"CVC - viewDidLoad");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    [rsCell.imgCell setFrame:CGRectMake(rsCell.imgCell.frame.origin.x, rsCell.imgCell.frame.origin.y, self.view.frame.size.width, rsCell.imgCell.frame.size.height)];
    
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 5;
//}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch ((ConnectCellOrder)indexPath.row)
    {
        case kConnectCellOrderFareInformation:
            NSLog(@"Indexpath, row 0");
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FareStoryboard" bundle:nil];
            FareViewController *fVC = (FareViewController*)[storyboard instantiateInitialViewController];
            [self.navigationController pushViewController: fVC animated: YES];
        }
            break;
            
        case kConnectCellOrderCustomerService:
            
        {
            [self showActionSheet];
            
//            NSURL *url = [NSURL URLWithString:@"telprompt://215-580-7800"];
//            if ( [[UIApplication sharedApplication] canOpenURL: url] )
//            {
//                [[UIApplication sharedApplication] openURL: url];
//            }
//            else
//            {
//                
//            }
            // 215-580-7800
            // 215-580-7853 (TDD/TTY)
        }
            
            break;
            
        case kConnectCellOrderFacebook:
        {
            NSURL *url = [NSURL URLWithString:@"fb://profile/174505962565714"];
            if ( [[UIApplication sharedApplication] canOpenURL: url] )
            {
                [[UIApplication sharedApplication] openURL: url];
            }
            else
            {
                // Otherwise open up a UIWebView and display SEPTA's facebook profile
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FacebookStoryboard" bundle:nil];
                FacebookViewController *fVC = (FacebookViewController*)[storyboard instantiateInitialViewController];
                [self.navigationController pushViewController: fVC animated: YES];
            }
        }
            break;
        
        case kConnectCellOrderTwitter:
        {
            NSURL *url = [NSURL URLWithString:@"twitter://user?screen_name=@SEPTA_SOCIAL"];
            if ( [[UIApplication sharedApplication] canOpenURL: url] )
            {
                [[UIApplication sharedApplication] openURL: url];
            }
            else
            {
                // Otherwise open up a UIWebView and display SEPTA_SOCIAL twitter page
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TwitterStoryboard" bundle:nil];
                TwitterViewController *tVC = (TwitterViewController*)[storyboard instantiateInitialViewController];
                [self.navigationController pushViewController: tVC animated: YES];
                
            }
        }
            
            break;
            
        case kConnectCellOrderComments:
            
            [self createCommentForm];
            
            break;
            
        case kConnectCellOrderLeaveFeedback:
            
            [self createFeedbackForm];
            
            break;
            
        default:
            break;
    }
    
    
    

}



#pragma mark - Comments
-(void) createCommentForm
{
    
//    QRootElement *root = [[QRootElement alloc] init];
//    root.title = @"Hello World";
//    root.controllerName = @"MyTestDialogController";
//    root.grouped = YES;
//    
//    QSection *section =  [[QSection alloc] init];
//    QLabelElement *label = [[QLabelElement alloc] initWithTitle:@"Hello" Value:@"fuckface!"];
//    
//    [root addSection: section];
//    [section addElement:label];
//    
//    UINavigationController *navigation = [QuickDialogController controllerWithNavigationForRoot:root];
//    [self presentModalViewController:navigation animated:YES];
    
//    MyTestDialogController *myDialogController = (MyTestDialogController*)[QuickDialogController controllerForRoot:root];
//    [[self navigationController] presentModalViewController: myDialogController animated:YES];
    
//    [self presentModalViewController:navigation animated:YES];
   
    
//    NSLog(@"Here!");
//    FeedbackQuickViewController *quickController = (FeedbackQuickViewController*) [[FeedbackQuickViewController alloc] initWithRoot:root];
//    [quickController setBackButtonName:@"commentsBack.png"];
//    [quickController setViewTitle:@"Comments"];
//    [[self navigationController] pushViewController:quickController animated:YES];
    
}

-(void) createCommentForm2
{
    
    return;
    
//    QRootElement *root = [[QRootElement alloc] init];
//    [root setTitle:@"Comment Form"];
//    [root setControllerName:@"FeedbackQuickViewController"];
//    [root setGrouped:YES];
//    
//    ////    QSection *spacer = [[QSection alloc] init];
//    ////    QSection *spacer2 = [[QSection alloc] init];
//    ////
//    ////    QLabelElement *blank = [[QLabelElement alloc] init];
//    ////    [blank setHidden:YES];
//    ////
//    ////    [spacer addElement:blank];
//    ////    [root addSection: spacer];
//    ////    [root addSection: spacer2];
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
//    //    QSection *dateTimeSection = [[QSection alloc] initWithTitle:@"Incident/Travel"];
//    //
//    //    NSDate *oneTimeToRuleThemAll = [NSDate date];
//    //    QDateTimeInlineElement *time = [[QDateTimeInlineElement alloc] initWithTitle:@"Time" date: oneTimeToRuleThemAll ];
//    //    [time setMode:UIDatePickerModeTime ];
//    //
//    //    QDateTimeInlineElement *date = [[QDateTimeInlineElement alloc] initWithTitle:@"Incident/Travel" date: oneTimeToRuleThemAll ];
//    //    [date setMode:UIDatePickerModeDate ];
//    //    date.key = @"incidentDate";
//    //
//    //    [dateTimeSection addElement:date];
//    //    [dateTimeSection addElement:time];
//    //
//    //    [root addSection: dateTimeSection];
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
//    //    [information addElement:date];
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
//            //            filteredDate = [[dateFormatter stringFromDate:[date dateValue] ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
//            //            filteredTime = [[timeFormatter stringFromDate:[date dateValue] ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
//            //            filteredComments = [@"This is a test of the iPhone SETPA App.  Please disregard." stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
//            //            NSString *newString = [NSString stringWithFormat:@"%@%@", urlString, postString];
//            //            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newString]];
//            
//            [request setHTTPMethod:@"POST"];
//            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//            [request setHTTPBody:postData];
//            
//            //            [request setValue: [NSString stringWithFormat:@"%d", [postString length]] forHTTPHeaderField:@"Content-length"];
//            
//            //            [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
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
//            //            NSLog(@"newString : %@", newString);
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
//            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered text" message:urlString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            //            [alert show];
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
//    NSLog(@"Here!");
//    FeedbackQuickViewController *quickController = (FeedbackQuickViewController*) [[FeedbackQuickViewController alloc] initWithRoot:root];
//    [quickController setBackButtonName:@"commentsBack.png"];
//    [quickController setViewTitle:@"Comments"];
//    [[self navigationController] pushViewController:quickController animated:YES];

    
//    CommentQuickViewController *quickController = (CommentQuickViewController*) [[CommentQuickViewController alloc] initWithRoot:root];
//    [quickController setBackButtonName:@"commentsBack.png"];
//    [quickController setViewTitle:@"Comments"];
//    [[self navigationController] pushViewController:quickController animated:YES];
    
    
}


#pragma mark - Feedback
-(void) createFeedbackForm
{
    
//    QRootElement *root = [[QRootElement alloc] init];
//    [root setTitle:@"App Feedback"];
//    [root setControllerName:@"FeedbackQuickViewController"];
//    [root setGrouped:YES];
//    
//    
//    // --==  Comment Section  ==--
//    NSArray *radioArray = [[NSArray alloc] initWithObjects:@"Bug", @"Crash", @"Suggestion", @"Bad Data", @"Other", nil];
//    
//    QSection *commentSection = [[QSection alloc] initWithTitle:@"Type of Feedback"];
//    QRadioElement *radioElement = [[QRadioElement alloc] initWithItems:radioArray selected:0 title:nil];
//    
//    [commentSection addElement: radioElement];
//    
//    [root addSection: commentSection];
//    
//    
//    // --==  Image Section  ==--
//    
//    // This didn't work out well.  Unable to tell if an image has been selected or not.  What crap!
//    
//    //    QSection *imageSection = [[QSection alloc] initWithTitle:@"Image:"];
//    //    UIImage *image = [[UIImage alloc] init];
//    //    QImageElement *imageElement = [[QImageElement alloc] initWithTitle:@"Tap to select" detailImage:image];
//    ////    [imageElement setTitle:@"Tap to select image"];
//    //
//    //    [imageSection addElement: imageElement];
//    //    [root addSection: imageSection];
//    QSection *imageButtonSection = [[QSection alloc] initWithTitle:@"Image:"];
//    QButtonElement *imageButtonElement = [[QButtonElement alloc] initWithTitle:@"Tap to select"];
//    
//    [imageButtonSection addElement: imageButtonElement];
//    [root addSection: imageButtonSection];
//    
//    imageButtonElement.onSelected = ^{
//        
//        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//        
//        [imagePicker setDelegate:self];
//        
//        [self presentModalViewController:imagePicker animated:YES];
//        
//    };
//    
//    
//    
//    // --==  Details Section  ==--
//    QSection *detailsSection = [[QSection alloc] initWithTitle:@"Details:"];
//    QMultilineElement *detailsMulti = [QMultilineElement new];
//    [detailsMulti setTitle:@"Details"];
//    
//    [detailsSection addElement: detailsMulti];
//    [root addSection: detailsSection];
//    
//    
//    // --==  Button Section  ==--
//    QSection *btnSection = [[QSection alloc] init];
//    QButtonElement *button = [[QButtonElement alloc] initWithTitle:@"Submit"];
//    
//    [btnSection addElement:button];
//    [root addSection:btnSection];
//    
//    
//    button.onSelected = ^{
//        
//        NSLog(@"Button Selection");
//        
//        if ( [MFMailComposeViewController canSendMail] )
//        {
//            
//            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
//            mailViewController.mailComposeDelegate = self;
//            
//            
//            [mailViewController setSubject:[NSString stringWithFormat:@"SEPTA iPhone (v%@) Feedback: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [radioArray objectAtIndex:[radioElement selected] ] ] ];
//            [mailViewController setToRecipients:[NSArray arrayWithObject:@"iosapp@septa.org"] ];
//            
//            [mailViewController setMessageBody:[detailsMulti textValue] isHTML:NO];
//            
//            if ( attachmentImage != nil )
//            {
//                NSData *myData = UIImagePNGRepresentation( attachmentImage );
//                
//                NSString *name = @"Untitled.png";
//                //                if ( [imageElement imageNamed] != nil )
//                //                    name = [imageElement imageValueNamed];
//                //
//                [mailViewController addAttachmentData:myData mimeType:@"image/png" fileName: name ];
//            }
//            
//            [self presentModalViewController:mailViewController animated:YES];
//            
//        }
//        
//        
//    };
//    
//    
//    FeedbackQuickViewController *quickController = (FeedbackQuickViewController*) [[FeedbackQuickViewController alloc] initWithRoot:root];
//    [[self navigationController] pushViewController:quickController animated:YES];
    
}




#pragma mark - UIActionSheet
-(void) showActionSheet
{
    NSString *actionSheetTitle = @"SEPTA's Customer Service"; //Action Sheet Title
//    NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *other1 = @"Call (215) 580-7800";
    NSString *other2 = @"TDD/TTY (215) 580-7853";
    NSString *cancelTitle = @"Cancel Button";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, nil];
//    [actionSheet showInView:self.view];
    
    [actionSheet setActionSheetStyle: UIActionSheetStyleBlackTranslucent];
    [actionSheet showFromTabBar: self.tabBarController.tabBar];

}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button pressed - %ld", (long)buttonIndex);
    
    switch (buttonIndex)
    {
        case 0:
        {
            NSURL *url = [NSURL URLWithString:@"telprompt://215-580-7800"];
            if ( [[UIApplication sharedApplication] canOpenURL: url] )
            {
                [[UIApplication sharedApplication] openURL: url];
            }
            else
            {
                
            }
        }
            break;
        case 1:
        {
            NSURL *url = [NSURL URLWithString:@"telprompt://215-580-7853"];
            if ( [[UIApplication sharedApplication] canOpenURL: url] )
            {
                [[UIApplication sharedApplication] openURL: url];
            }
            else
            {
                
            }
        }
            break;
        default:
            break;
    }
    
}


#pragma mark - MailComposer
-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -- ImagePickerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    attachmentImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    
}


@end
