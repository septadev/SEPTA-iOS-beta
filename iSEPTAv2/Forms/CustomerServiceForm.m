//
//  CustomerServiceForm.m
//  iSEPTA
//
//  Created by septa on 1/7/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import "CustomerServiceForm.h"

@implementation CustomerServiceForm

-(NSArray*) fields
{
    
    return @[
             @{@"textLabel.color": [UIColor redColor], FXFormFieldKey: @"date", FXFormFieldType: FXFormFieldTypeDateTime, FXFormFieldHeader: @"When", FXFormFieldTitle: @"Date"},             
             
             @{@"textLabel.color": [UIColor redColor], FXFormFieldKey: @"where", FXFormFieldType: FXFormFieldTypeText, FXFormFieldTitle: @"Where",FXFormFieldHeader:@"Details"},

             @{FXFormFieldKey: @"mode", FXFormFieldTitle: @"Mode", FXFormFieldType: FXFormFieldTypeText},
             @{FXFormFieldKey: @"route", FXFormFieldTitle: @"Route", FXFormFieldType: FXFormFieldTypeText},
             @{FXFormFieldKey: @"destination", FXFormFieldTitle: @"Destination", FXFormFieldType: FXFormFieldTypeText},
             
             @{@"textLabel.color": [UIColor redColor], FXFormFieldKey: @"comment", FXFormFieldHeader: @"Comment", FXFormFieldTitle: @"Comment", FXFormFieldType: FXFormFieldTypeLongText},
            
             @{@"textLabel.color": [UIColor redColor], FXFormFieldKey: @"firstName", FXFormFieldType: FXFormFieldTypeText, FXFormFieldHeader: @"Contact Information", FXFormFieldTitle: @"First Name"},
             @{@"textLabel.color": [UIColor redColor], FXFormFieldKey: @"lastName", FXFormFieldType: FXFormFieldTypeText, FXFormFieldTitle: @"Last Name"},
             @{@"textLabel.color": [UIColor redColor], FXFormFieldKey: @"emailAddress", FXFormFieldType: FXFormFieldTypeEmail, FXFormFieldTitle: @"Email Address"},
             @{FXFormFieldKey: @"phoneNumber", FXFormFieldTitle: @"Phone Number"},
             
             @{FXFormFieldTitle: @"Submit", FXFormFieldHeader: @"", FXFormFieldAction: @"submitRegistrationForm:"},
             
             ];
    
    
}


-(NSDictionary*) modeField
{
    NSLog(@"CSF - modeField");
    NSArray *modes = @[@"MFL",@"BSL",@"NHSL",@"Trolley",@"Bus",@"Regional Rail",@"CCT Connect"];
    
    return @{FXFormFieldOptions: modes, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
    
}


-(NSDictionary*) routeField
{

    NSLog(@"CSF - routeField");
    if ( _mode != nil )
    {
        
        NSMutableArray *routes = [[NSMutableArray alloc] init];;
        if (    [_mode isEqualToString: @"MFL"] ||
            [_mode isEqualToString:@"BSL"]  ||
            [_mode isEqualToString:@"NHSL"] ||
            [_mode isEqualToString:@"CCT Connect"] )
        {
            [routes addObject:@"-"];
        }
        else
        {
            FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
            if ( ![database open] )
            {
                [database close];
                return @{FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldValueTransformer: ^(__unused id value){
                    return @"-";
                }};
                
            }
            
            FMResultSet *results;
            NSString *queryStr;
            
            if ( [_mode isEqualToString:@"Regional Rail"] )
                queryStr = @"SELECT route_id FROM routes_rail ORDER BY route_id;";
            else if ( [_mode isEqualToString:@"Bus"] )
                queryStr = @"SELECT route_short_name FROM routes_bus WHERE route_type=3 ORDER BY route_short_name;";
            else if ( [_mode isEqualToString:@"Trolley"] )
                queryStr = @"SELECT route_short_name FROM routes_bus WHERE route_type=0 AND route_short_name != 'NHSL' ORDER BY route_short_name;";
            
            results = [database executeQuery: queryStr];
            if ( [database hadError] )  // Check for errors
            {
                return @{FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldValueTransformer: ^(__unused id value){
                    return @"-";
                }};
            }
            
            while ( [results next] )
            {
                [routes addObject: [results stringForColumnIndex:0] ];
            }
            
            [results  close];
            [database close];
            
            //routes = @[@"AIR",@"CHE",@"CHW",@"CYN",@"FOX",@"GC",@"LAN",@"MED",@"NOR",@"PAO",@"TRE",@"WAR",@"WIL",@"WTR"];
        }
        
        return @{FXFormFieldOptions: routes, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
    }
    else
    {
        return @{FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldValueTransformer: ^(__unused id value){
            return @"-";
        }};
    }
    
}



-(NSDictionary*) destinationField
{
    
    NSLog(@"CSF - destinationField");
    if ( ( _mode != nil ) && (_route != nil ) )
    {
        
        NSMutableArray *destArr = [[NSMutableArray alloc] init];
        
        if ( [_mode isEqualToString:@"Regional Rail"] )
        {
            
            [destArr addObject:@"Center City"];
            FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
            if ( [database open] )
            {
                
                FMResultSet *results;
                NSString *queryStr;
                
                queryStr = [NSString stringWithFormat:@"SELECT route_short_name FROM routes_rail WHERE route_id='%@';",_route];
                
                results = [database executeQuery: queryStr];
                if ( ![database hadError] )  // Check for errors
                {
                    
                    while ( [results next] )
                    {
                        [destArr addObject: [results stringForColumnIndex:0] ];
                    }
                    
                }  // if ( ![database hadError] )
                [results close];
                
            }  // if ( [database open] )
            
            [database close];
            return @{FXFormFieldOptions: destArr, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
            
        }
        else
        {
            
            FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
            if ( [database open] )
            {
                
                FMResultSet *results;
                NSString *queryStr;
                
                queryStr = [NSString stringWithFormat:@"SELECT DirectionDescription FROM bus_stop_directions WHERE Route='%@';",_route];
                
                results = [database executeQuery: queryStr];
                if ( ![database hadError] )  // Check for errors
                {
                    
                    while ( [results next] )
                    {
                        [destArr addObject: [results stringForColumnIndex:0] ];
                    }
                    
                }  // if ( ![database hadError] )
                [results close];
                
            }  // if ( [database open] )
            
            [database close];
            return @{FXFormFieldOptions: destArr, FXFormFieldPlaceholder: @"-", FXFormFieldAction: @"updateFields"};
            
        }
        
    }  // if ( _mode != nil )
    
    
    return @{FXFormFieldType: FXFormFieldTypeLabel, FXFormFieldValueTransformer: ^(__unused id value){
        return @"-";
    }};
    
    
}


-(BOOL) validateForm
{
    
    // These are required fields
    if ( ( self.where == nil ) || (self.date == nil ) || ( self.comment == nil ) || (self.firstName == nil ) || ( self.lastName == nil ) || (self.emailAddress == nil ) )
    {
        return NO;
    }
    
    return YES;
}


+(NSArray*) returnAllKeyValues
{
    return [NSArray arrayWithObjects:@"where",@"mode",@"route",@"destination",@"comment",@"firstName",@"lastName",@"phoneNumber",@"emailAddress",nil];
}


+(NSArray*) returnAllRequiredValues
{
    return [NSArray arrayWithObjects:@"date",@"where",@"comment",@"firstName",@"lastName",@"emailAddress",nil];
}


@end
