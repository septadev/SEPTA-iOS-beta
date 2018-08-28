//
//  FavoriteNextToArriveViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

class FavoriteNextToArriveViewModel: BaseNextToArriveInfoViewModel {
    var favorite: Favorite
    init(favorite: Favorite, delegate: UpdateableFromViewModel) {
        self.favorite = favorite
        super.init()
        self.delegate = delegate
        groupedTripData = groupNextToArriveTripsByRoute(trips: favorite.nextToArriveTrips)
    }

    func groupNextToArriveTripsByRoute(trips _: [NextToArriveTrip]) -> [[NextToArriveTrip]] {
        var groupedTripData = NextToArriveGrouper.buildNextToArriveTripSections(trips: favorite.nextToArriveTrips)
        groupedTripData = includeOnlyTheFirstThreeRoutes(groupedTripData: groupedTripData)
        return groupedTripData
    }

    func includeOnlyTheFirstThreeRoutes(groupedTripData: [[NextToArriveTrip]]) -> [[NextToArriveTrip]] {
        if groupedTripData.count > 3 {
            return Array(groupedTripData[0 ... 2])
        } else {
            return groupedTripData
        }
    }

    override func transitMode() -> TransitMode {
        return favorite.transitMode
    }

    func viewTitle() -> String {
        return scheduleRequest().transitMode.nextToArriveInfoDetailTitle()
    }

    override func tripDetailIsAvailable(forTrip _: NextToArriveTrip) -> Bool {
        return false
    }

    func ntaUnavailable() -> Bool {
        return groupedTripData.count < 1
    }

    override func subscribe() {
    }
}
