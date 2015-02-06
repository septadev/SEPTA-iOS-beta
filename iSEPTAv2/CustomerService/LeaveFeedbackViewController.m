//
//  LeaveFeedbackViewController.m
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "LeaveFeedbackViewController.h"

@interface LeaveFeedbackViewController ()

@end

@implementation LeaveFeedbackViewController

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
    
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    
    self.formController.delegate = self;
    self.formController.form = [[FeedbackForm alloc] init];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
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


- (void)submitRegistrationForm:(UITableViewCell<FXFormFieldCell> *)cell
{
    
    FeedbackForm *form = cell.field.form;
    
    // Check that the required fields have been entered
    
        if ( [MFMailComposeViewController canSendMail] )
        {

            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;


            [mailViewController setSubject:[NSString stringWithFormat:@"SEPTA iPhone (v%@) Feedback: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], form.feedbackType ] ];
            [mailViewController setToRecipients:[NSArray arrayWithObject:@"iosapp@septa.org"] ];

            [mailViewController setMessageBody:form.details isHTML:NO];

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

            [self presentViewController:mailViewController animated:YES completion:nil];
            
        }
    
    
    // Access the fields as: form.emailAddress
    //    NSLog(@"Submitted");
    
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
