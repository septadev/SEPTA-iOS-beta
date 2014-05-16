//
//  CommentsForm.m
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "CommentsFormTemp.h"

@implementation CommentsFormTemp
{

}


-(id) init
{
    self = [super init];
    if ( self )
    {
//        _field1 = NSNotFound;
//        _field2 = NSNotFound;
    }
    return self;
}



- (NSDictionary *)field1Field
{
    NSArray *months = @[@"January",
                        @"February",
                        @"March",
                        @"April",
                        @"May",
                        @"June",
                        @"July",
                        @"August",
                        @"September",
                        @"October",
                        @"November",
                        @"December"];
    
    return @{FXFormFieldOptions: months, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
}

//- (NSDictionary *)field2Field
//{
//    NSMutableArray *days = [NSMutableArray array];
//    if (self.field1 != NSNotFound )
//    {
//        NSArray *daysPerMonth = @[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31];
//        NSInteger max = [daysPerMonth[self.field1] integerValue];
//        for (NSInteger i = 1; i <= max; i++)
//        {
//            [days addObject:@(i)];
//        }
//        return @{FXFormFieldOptions: days, FXFormFieldPlaceholder: @"-"};
//    }
//    else
//    {
//        return @{FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldValueTransformer: ^(__unused id value){
//            return @"-";
//        }};
//    }
//
//    
//}


-(NSDictionary*) whenField
{
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setDateFormat:@"M/d/yy hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    return @{@"textLabel.color": [UIColor redColor], @"detailTextLabel.text": currentTime};
}


-(NSDictionary*) whereField
{
    return @{@"textLabel.color": [UIColor redColor]};
}

-(NSDictionary*) modeField
{
    
    NSArray *modes = @[@"MFL",@"BSL",@"NHSL",@"Trolley",@"Bus",@"Regional Rail",@"CCT Connect"];

    return @{FXFormFieldOptions: modes, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
    
}

-(NSDictionary*) routesField
{
    
    if ( _mode != nil )
    {
        NSLog(@"Do stuff");
        NSArray *routes = @[@"1",@"2",@"3"];
        return @{FXFormFieldOptions: routes, FXFormFieldPlaceholder: @"-"};
    }
    else
    {
        return @{FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldValueTransformer: ^(__unused id value){
            return @"-";
        }};
    }

}


//-(NSDictionary*) dateTimeField
//{
//    
//    // get current date/time
//    NSDate *today = [NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//
//    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
//    [dateFormatter setDateFormat:@"M/d/yy hh:mm a"];
//    NSString *currentTime = [dateFormatter stringFromDate:today];
//
//    //NSLog(@"User's current time in their preference format:%@",currentTime);
//
////    self.dateTime = currentTime;
//    self.startingDateTime = currentTime;
//    
//    return @{@"textLabel.color": [UIColor redColor], @"detailTextLabel.text": currentTime};
//}
//
//
//-(NSDictionary*) whereField
//{
//    return @{@"textLabel.color": [UIColor redColor]};
//}
//
//-(NSDictionary*) commentField
//{
//    return @{@"textLabel.color": [UIColor redColor]};
//}
//
//-(NSDictionary*) firstNameField
//{
//    return @{@"textLabel.color": [UIColor redColor]};
//}
//
//-(NSDictionary*) lastNameField
//{
//    return @{@"textLabel.color": [UIColor redColor]};
//}
//
//-(NSDictionary*) emailAddressField
//{
//    return @{@"textLabel.color": [UIColor redColor]};
//}

//-(NSDictionary*) modeField
//{
//
//    NSArray *modes = @[@"MFL",@"BSL",@"NHSL",@"Trolley",@"Bus",@"Regional Rail",@"CCT Connect"];
//    
//    return @{FXFormFieldOptions: modes, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
//
//}



-(BOOL) validateForm
{

//    // These are required fields
//    if ( ( self.where == nil ) || (self.dateTime == nil ) || ( self.comment == nil ) || (self.firstName == nil ) || ( self.lastName == nil ) || (self.emailAddress == nil ) )
//    {
//        return NO;
//    }
    
    return YES;
}
//
//-(void) filterData
//{
//    
//}
//
//
//-(NSDictionary*) modeField
//{
//    
//    NSLog(@"modeFiled called!");
//    NSArray *modes = @[@"MFL",@"BSL",@"NHSL",@"Trolley",@"Bus",@"Regional Rail",@"CCT Connect"];
//    return @{FXFormFieldOptions: modes, FXFormFieldPlaceholder:@"-", FXFormFieldAction: @"updateFields"};
//}


//-(NSDictionary*) routeField
//{
//
//    NSLog(@"routeField");
//
//    NSArray *routes;
//    
//    if ( [self.mode isEqualToString:@"Bus"] )
//    {
//        routes = @[@"1",@"2",@"3"];
//    }
//    else if ( [self.mode isEqualToString:@"Trolley"] )
//    {
//        routes = @[@"10",@"11",@"13",@"15"];
//    }
//    
////    return @{FXFormFieldOptions: routes, FXFormFieldPlaceholder:@"-"};
//
//    if ( self.mode != nil )
//    {
//        return @{FXFormFieldOptions: routes, FXFormFieldPlaceholder:@"-"};
//    }
//    else
//    {
//        return @{FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldValueTransformer: ^(__unused id value)
//        {
//            return @"-";
//        }};
//    }
//    
//}


//- (NSArray *)fields
//{
//    
//    
////    return @{FXFormFieldOptions: months, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
//    
//    return @[
//    
//             @{FXFormFieldKey:@"dateTime", FXFormFieldHeader: @"Incident Date Time", FXFormFieldType: FXFormFieldTypeDateTime, FXFormFieldTitle: @"When?"},
//             
//             @{FXFormFieldKey:@"where", FXFormFieldHeader: @"Details", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldTitle: @"Where?"},
//             //@{FXFormFieldKey:@"mode", FXFormFieldOptions: @[@"Regional Rail",@"Market-Frankford Line",@"Broad Street Line", @"Trolley Lines", @"Norristown High Speed Line", @"Buses", @"CCT Connect"], FXFormFieldCell: [FXFormOptionPickerCell class]},
//             @{FXFormFieldKey:@"mode", FXFormFieldOptions: _modes}, // FXFormFieldAction:@"action"},
//             @"route",
//             @"destination",
//             @{FXFormFieldKey:@"blockTrain", FXFormFieldTitle: @"Block or Train"},
//             @{FXFormFieldKey:@"vehicle", FXFormFieldTitle: @"Vehicle or Car"},
//             @{FXFormFieldKey:@"comment", FXFormFieldType: FXFormFieldTypeLongText},
//             @{FXFormFieldKey:@"employee_description", FXFormFieldTitle: @"Employee Description", FXFormFieldType: FXFormFieldTypeLongText},
//             
//             @{FXFormFieldKey: @"firstName", FXFormFieldHeader: @"Your Contact Info"},
//             @"lastName",
//             
//             @"phoneNumber",
//             @{FXFormFieldKey: @"emailAddress", FXFormFieldType: FXFormFieldTypeEmail},
//             
//             @{FXFormFieldTitle: @"Submit", FXFormFieldHeader: @" ", FXFormFieldAction: @"submitRegistrationForm:"},
//             ];
//    
//}



//+(NSArray*) returnAllKeyValues
//{
//    return [NSArray arrayWithObjects:@"dateTime",@"where",@"mode",@"route",@"destination",@"blockTrain",@"vehicle",@"comment",@"employee_description",@"firstName",@"lastName",@"phoneNumber",@"emailAddress",nil];
//}
//
//
//+(NSArray*) returnAllRequiredValues
//{
//    return [NSArray arrayWithObjects:@"dateTime",@"where",@"comment",@"firstName",@"lastName",@"emailAddress",nil];
//}


@end
