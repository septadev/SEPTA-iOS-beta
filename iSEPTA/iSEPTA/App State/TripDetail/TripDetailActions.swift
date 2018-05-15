//
//  TripDetailActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

protocol TripDetailAction: SeptaAction {}

struct UpdateTripDetails: TripDetailAction {
    let tripDetails: NextToArriveStop
    let description: String = "Updating Trip Details"
}

struct ClearTripDetails: TripDetailAction {

    let description: String = "Clear out Trip Details"
}
