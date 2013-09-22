//
//  CommentForm.m
//  iSEPTA
//
//  Created by Justin Brathwaite on 4/14/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "CommentForm.h"
#import <QuartzCore/QuartzCore.h>

#define NOTIFY_AND_LEAVE(MESSAGE) {[self cleanup:MESSAGE]; return;}
#define DATA(STRING)	[STRING dataUsingEncoding:NSUTF8StringEncoding]
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
// Posting constants
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"
@interface CommentForm ()

@end

@implementation CommentForm
@synthesize scrollView;
@synthesize pagecontrol;
@synthesize firstview;
@synthesize secondview;
@synthesize thirdview;
@synthesize Name;
@synthesize phoneNumber;
@synthesize emailAddress;
@synthesize picture;
@synthesize pic;
@synthesize details;

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
    [self createMenu];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)createMenu
{
    CGRect frameToolBar = CGRectMake(0, 0.0, 195, 50.0);
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:frameToolBar];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    [toolBar sizeToFit];
    
    
    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goButtonPressed:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *SendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                     style:UIBarButtonItemStyleDone target:self action:@selector(goButtonPressed:)];
    CancelButton.tintColor= [UIColor blackColor];
    SendButton.tintColor= [UIColor blackColor];
    toolBar.items = [NSArray arrayWithObjects:CancelButton,flexibleSpace,SendButton, nil ];
   

    
    
    self.view.backgroundColor =[UIColor whiteColor];
     scrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 43.0, 320, 400)];
    scrollView.delegate =self;
    scrollView.clipsToBounds = YES;
    [self.view addSubview:scrollView];
    scrollView.backgroundColor =[UIColor blueColor];
    [scrollView setPagingEnabled:YES];
    pagecontrol = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 415, 320, 45)];
    pagecontrol.UserInteractionEnabled=YES;
    [pagecontrol addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    pagecontrol.backgroundColor =[UIColor blackColor];
    pagecontrol.numberOfPages =3;
    pagecontrol.currentPage=0;
    [self.view addSubview:pagecontrol];
    [self.view addSubview:toolBar];
    
    CGRect frame;
    frame.origin.x = scrollView.frame.size.width * 0;
    frame.origin.y = 0;
    frame.size = scrollView.frame.size;
    
  firstview = [[UIView alloc] initWithFrame:frame];
    firstview.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"splashblank.png"]];
    [self setUpFirstView];
    [scrollView addSubview:firstview];
    
    
    CGRect secondframe;
    secondframe.origin.x = scrollView.frame.size.width * 1;
    secondframe.origin.y = 0;
    secondframe.size = scrollView.frame.size;
    
    secondview = [[UIView alloc] initWithFrame:secondframe];
    secondview.backgroundColor =[UIColor purpleColor];
    [scrollView addSubview:secondview];
    
    
    CGRect thirdframe;
    thirdframe.origin.x = scrollView.frame.size.width * 2;
    thirdframe.origin.y = 0;
    thirdframe.size = scrollView.frame.size;
    
    thirdview = [[UIView alloc] initWithFrame:thirdframe];
    thirdview.backgroundColor =[UIColor greenColor];
    [scrollView addSubview:thirdview];
    
     scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, scrollView.frame.size.height);
    
}
- (void)setUpFirstView
{
    UIScrollView *firstViewscrollView = [[UIScrollView alloc] initWithFrame:firstview.bounds];
    firstViewscrollView.contentSize = CGSizeMake(320, 500);
    firstViewscrollView.showsVerticalScrollIndicator = YES;
    [firstview addSubview:firstViewscrollView];

    UILabel *yourNamelbl;
    yourNamelbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 100, 20.0)];
    yourNamelbl.font = [UIFont systemFontOfSize:17.0];
    yourNamelbl.textAlignment = UITextAlignmentLeft;
    yourNamelbl.text= [NSString stringWithFormat:@"Your Name"];
    yourNamelbl.backgroundColor =[UIColor clearColor];
    yourNamelbl.textColor=[UIColor whiteColor];
    [firstViewscrollView addSubview:yourNamelbl];
    
    
    //Customer Name
    CGRect frameName = CGRectMake(10.0, 50.0, 220.0, 30.0);
    Name= [[UITextField alloc] initWithFrame:frameName];
    Name.borderStyle =UITextBorderStyleRoundedRect;
    Name.backgroundColor =[UIColor whiteColor];
    [firstViewscrollView addSubview:Name];
    
    UILabel *phoneNUmberlbl;
    phoneNUmberlbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 95.0, 200, 20.0)];
    phoneNUmberlbl.font = [UIFont systemFontOfSize:17.0];
    phoneNUmberlbl.textAlignment = UITextAlignmentLeft;
    phoneNUmberlbl.text= [NSString stringWithFormat:@"Phone Number"];
    phoneNUmberlbl.backgroundColor =[UIColor clearColor];
    phoneNUmberlbl.textColor=[UIColor whiteColor];
    [firstViewscrollView addSubview:phoneNUmberlbl];
    

    //Customer Phone Number
    CGRect framePhoneNumber = CGRectMake(10.0, 120.0, 220.0, 30.0);
    phoneNumber= [[UITextField alloc] initWithFrame:framePhoneNumber];
    phoneNumber.borderStyle =UITextBorderStyleRoundedRect;
    phoneNumber.backgroundColor =[UIColor whiteColor];
    [firstViewscrollView addSubview:phoneNumber];

    UILabel *yourEmaillbl;
    yourEmaillbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 165.0, 250, 20.0)];
    yourEmaillbl.font = [UIFont systemFontOfSize:17.0];
    yourEmaillbl.textAlignment = UITextAlignmentLeft;
    yourEmaillbl.text= [NSString stringWithFormat:@"Your Email Address"];
    yourEmaillbl.backgroundColor =[UIColor clearColor];
    yourEmaillbl.textColor=[UIColor whiteColor];
    [firstViewscrollView addSubview:yourEmaillbl];
    
    //Customer Email Address
    CGRect frameEmail = CGRectMake(10.0, 190, 220.0, 30.0);
    emailAddress= [[UITextField alloc] initWithFrame:frameEmail];
    emailAddress.borderStyle =UITextBorderStyleRoundedRect;
    emailAddress.backgroundColor =[UIColor whiteColor];
    [firstViewscrollView addSubview:emailAddress];

   
    
    UILabel *detailslbl;
    detailslbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 240.0, 100, 20.0)];
    detailslbl.font = [UIFont systemFontOfSize:17.0];
    detailslbl.textAlignment = UITextAlignmentLeft;
    detailslbl.text= [NSString stringWithFormat:@"Details"];
    detailslbl.backgroundColor =[UIColor clearColor];
    detailslbl.textColor=[UIColor whiteColor];
    [firstViewscrollView addSubview:detailslbl];
    
    CGRect frameDetails = CGRectMake(10.0, 265, 270.0, 200.0);
    details= [[UITextView alloc] initWithFrame:frameDetails];
    details.layer.cornerRadius = 5;
    details.clipsToBounds = YES;
    details.backgroundColor =[UIColor whiteColor];
    
    [firstViewscrollView addSubview:details];
    
    
    pic = [[UIImagePickerController alloc] init];
	pic.delegate = self;
    
	pic.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	
    
	  

    
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pagecontrol.currentPage = page;
}
- (void)changePage:(UIPageControl *)pagecontroller
{
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pagecontrol.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

-(void) goButtonPressed:(id)sender
{
    //[self presentModalViewController:pic animated:YES];  
    [self dismissModalViewControllerAnimated:YES];
    }

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	//
     picture= [info objectForKey:UIImagePickerControllerEditedImage];
    //if (!picture)
	picture = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
   // picture =[self imageWithImage:picture];
    
   NSData *imageData=UIImageJPEGRepresentation(picture, .3);
  // NSLog(@"length %d",[imageData length]) ;
 // NSString *myString = [[NSString alloc] initWithData:imageData encoding:NSASCIIStringEncoding];
   // NSLog(@"hhk %@",myString);
 NSString *start =@"ahhaha"; 
    NSString *end = [self base64forData:imageData]; 
   // NSLog(@"%@",end);
    NSMutableDictionary* post_dic = [[NSMutableDictionary alloc] init];
    [post_dic setObject:end forKey:@"image"];
    [post_dic setObject:start forKey:@"start"];
    NSData *requestBody =[self generateFormDataFromPostDictionary:post_dic];
    NSURL *url = [NSURL URLWithString:@"http://www3.septa.org/iPhonepush/planmytrip.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    //NSData *requestBody = [@"start:test&password:y" dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody:requestBody];
    NSURLResponse *response = NULL;
    NSError *requestError = NULL;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] ;
	
	NSLog(@"responseString: %@", responseString);

   [picker dismissModalViewControllerAnimated:YES];
}

- (UIImage *)imageWithImage:(UIImage *)image {
   
   UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, 3200, 1000)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

                           - (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict
    {
        id boundary = @"------------0x0x0x0x0x0x0x0x";
        NSArray* keys = [dict allKeys];
        NSMutableData* result = [NSMutableData data];
        
        for (int i = 0; i < [keys count]; i++) 
        {
            id value = [dict valueForKey: [keys objectAtIndex:i]];
            [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            if ([value isKindOfClass:[NSData class]]) 
            {
                NSLog(@"entered");
                // handle image data
                NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
                [result appendData: DATA(formstring)];
                [result appendData:value];
            }
            else 
            {
                // all non-image fields assumed to be strings
                NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
                [result appendData: DATA(formstring)];
                [result appendData:DATA(value)];
            }
            
            NSString *formstring = @"\r\n";
            [result appendData:DATA(formstring)];
        }
        
        NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
        [result appendData:DATA(formstring)];
        return result;
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

@end
