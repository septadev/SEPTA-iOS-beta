//
//  CustomerServiceTableViewController.m
//  iSEPTA
//
//  Created by septa on 5/20/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CustomerServiceTableViewController.h"
//#import "FeedbackQuickViewController.h"

@interface CustomerServiceTableViewController ()

@end

@implementation CustomerServiceTableViewController
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

//    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ] ];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    float x; // = 9.1f;
    float y; // = 9.1f;
    
    x = y = 9.1f;
    
    CGRect bounds = self.imgColorBarCall.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bounds
                                                   byRoundingCorners: UIRectCornerTopLeft
                                                         cornerRadii: CGSizeMake(x,y)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.imgColorBarCall.layer.mask = maskLayer;
    
    
    bounds = self.imgColorBarComments.bounds;
    maskPath = [UIBezierPath bezierPathWithRoundedRect: bounds
                                     byRoundingCorners: UIRectCornerBottomLeft
                                           cornerRadii: CGSizeMake(x,y)];
    
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    [self.imgColorBarComments.layer setMask: maskLayer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSLog(@"s/r - %d/%d", indexPath.section, indexPath.row);

    if ( indexPath.section == 1 && indexPath.row == 0 )
    {
        [self createForm];
    }
    
}


-(void) createForm
{
    
//    QRootElement *root = [[QRootElement alloc] init];
//    [root setTitle:@"Comment Form"];
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
////    QSection *imageSection = [[QSection alloc] initWithTitle:@"Image:"];
////    UIImage *image = [[UIImage alloc] init];
////    QImageElement *imageElement = [[QImageElement alloc] initWithTitle:@"Tap to select" detailImage:image];
//////    [imageElement setTitle:@"Tap to select image"];
////    
////    [imageSection addElement: imageElement];
////    [root addSection: imageSection];
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
//            [mailViewController setSubject:[NSString stringWithFormat:@"SEPTA iPhone Feedback: %@", [radioArray objectAtIndex:[radioElement selected] ] ] ];
//            [mailViewController setToRecipients:[NSArray arrayWithObject:@"iosapp@septa.org"] ];
//            
//            [mailViewController setMessageBody:[detailsMulti textValue] isHTML:NO];
//
//            if ( attachmentImage != nil )
//            {
//                NSData *myData = UIImagePNGRepresentation( attachmentImage );
//                
//                NSString *name = @"Untitled.png";
////                if ( [imageElement imageNamed] != nil )
////                    name = [imageElement imageValueNamed];
////                
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


- (void)viewDidUnload {
    [self setImgColorBarCall:nil];
    [self setImgColorBarFacebook:nil];
    [self setImgColorBarTwitter:nil];
    [self setImgColorBarComments:nil];
    [self setImgIconCall:nil];
    [self setImgIconFacebook:nil];
    [self setImgIconTwitter:nil];
    [self setImgIconComments:nil];
    [super viewDidUnload];
}

@end
