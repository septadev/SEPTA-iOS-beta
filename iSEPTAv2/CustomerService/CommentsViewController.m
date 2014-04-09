//
//  CommentsViewController.m
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "CommentsViewController.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"initNib?!?!");
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
    self.formController.form = [[CommentsForm alloc] init];
    

    
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
    
    CommentsForm *form = cell.field.form;
    
    // Check that the required fields have been entered
    
    if ( ( [form.where length] > 0 ) && ( [form.comment length] > 0 ) && ( [form.firstName length] > 0 ) && ( [form.lastName length] > 0 )  && ( [form.emailAddress length] > 0 ) )
    {
        NSLog(@"Submit Data");
        [self submitData:form];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Required Fields Missing!" message:@"Please fill in all fields in red." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    // Access the fields as: form.emailAddress
//    NSLog(@"Submitted");
    
}


-(void) submitData:(CommentsForm *) form
{
    
    NSString *filteredName;
    NSString *filteredPhone;
    NSString *filteredEmail;
    NSString *filteredDate;
    NSString *filteredLocation;
    NSString *filteredRoute;
    NSString *filteredVehicle;
    NSString *filteredBlock;
    NSString *filteredTime;
    NSString *filteredDestination;
    NSString *filteredMode;
    NSString *filteredCommentType;
    NSString *filteredEmployee;  // First textarea
    NSString *filteredComments;  // Details (second) textarea
    
    filteredName  = [[NSString stringWithFormat:@"%@ %@", form.firstName, form.lastName] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    filteredPhone = [form.phoneNumber stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    filteredEmail = [form.emailAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    filteredDate  = [form.dateTime stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    filteredLocation = [form.where stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    filteredMode     = [form.mode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    filteredRoute  = [form.route stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    filteredVehicle = [form.vehicle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    filteredBlock   = [form.blockTrain stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    filteredComments = [form.comment stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    filteredDestination = [form.destination stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    filteredEmployee = [form.employee_description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString *urlString = @"http://www.septa.org/cs/comment/FormMail.cgi";

    // Removed the ? from the beginning of POST string
    NSString *postString = [NSString stringWithFormat:@"recipient=cservice%%40septa.org&wl_tp=Empolyee%%2CComments&subject=Inquiry+from+www.septa.org&required=Name%%2Cemail%%2Cphone&Name=%@&phone=%@&email=%@&Incident+Date=%@&Boarding+Location=%@&route=%@&vehicle=%@&block=%@&Time+of+Incident=%@&Final+Destination=%@&Comment=%@&Employee=%@&Comments=%@&Mode=%@", filteredName, filteredPhone, filteredEmail, filteredDate, filteredLocation, filteredRoute, filteredVehicle, filteredBlock, filteredTime, filteredDestination, filteredCommentType, filteredEmployee, filteredComments, filteredMode];

    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString] ];


    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:postData];


    NSHTTPURLResponse *urlResponse;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];

    int statusCode = [urlResponse statusCode];
    int errorCode = error.code;

    NSLog(@"urlString : %@", urlString);
    NSLog(@"postString: %@", postString);

    NSLog(@"status: %d, errorCode: %d", statusCode, errorCode);
    NSString *dataStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSString *content = [NSString stringWithUTF8String:[responseData bytes] ];
    NSLog(@"response: %@", dataStr);
    NSLog(@"content : %@", content);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:@"Your comment has been submitted." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];

    //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered text" message:urlString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //            [alert show];

    [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"CSVC - Dismissed Customer Form"); }];
    
    
}



@end
