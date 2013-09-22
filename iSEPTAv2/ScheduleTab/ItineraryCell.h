//
//  StopTimesCell.h
//  iSEPTA
//
//  Created by apessos on 12/11/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol RouteSelectionCellProtocol
//@required
//-(void) flipStopNamesButtonPressed;
//-(void) getStopNamesButtonPressed:(NSInteger) row;
//
//@end

@protocol ItineraryCellProtocol <NSObject>
@required

//-(void) switchDirectionButtonTapped;
-(void) flipStopNamesButtonTapped;
-(void) getStopNamesButtonTapped:(NSInteger) startEND;  // start = 1, END = 0

@end


@interface ItineraryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnEnd;


//@property (weak, nonatomic) IBOutlet UIButton *btnSwitchStops;

@property (weak, nonatomic) IBOutlet UIButton *btnFlipDirections;
//@property (weak, nonatomic) IBOutlet UILabel *lblDirectionToFrom;
//@property (weak, nonatomic) IBOutlet UILabel *lblRouteShortName;

@property (weak, nonatomic) IBOutlet UIButton *btnStartStopName;
@property (weak, nonatomic) IBOutlet UIButton *btnEndStopName;

//@property (weak, nonatomic) IBOutlet UILabel *lblStartStopName;
//@property (weak, nonatomic) IBOutlet UILabel *lblEndStopName;

@property (nonatomic) NSInteger row;
@property (weak, nonatomic) id<ItineraryCellProtocol> delegate;


/*
 
 Methods Needed:
    
 
 */
//-(void) flipDataInCell: (StopTimesCell*) firstCell withCell: (StopTimesCell*) secondCell;
//-(void) flipDataWithCell: (StopTimesCell*) secondCell;


@end
