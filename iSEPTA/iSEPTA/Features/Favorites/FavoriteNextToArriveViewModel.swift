//
//  FavoriteNextToArriveViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule

class FavoriteNextToArriveViewModel: BaseNextToArriveInfoViewModel {
    let favorite: Favorite
    init(favorite: Favorite, delegate: UpdateableFromViewModel) {
        self.favorite = favorite
        super.init()
        self.delegate = delegate
        groupedTripData = NextToArriveGrouper.buildNextToArriveTripSections(trips: favorite.nextToArriveTrips)

    }

    override func transitMode() -> TransitMode {
        return favorite.transitMode
    }

    func viewTitle() -> String {
        return scheduleRequest().transitMode.nextToArriveInfoDetailTitle()
    }

    override func subscribe() {
    }
}
