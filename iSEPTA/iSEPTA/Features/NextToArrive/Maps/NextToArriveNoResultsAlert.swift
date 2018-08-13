//
//  NextToArriveNoResultsAlert.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveNoResultsAlert: NextToArriveUpdateStatusWatcherDelegate {
    weak var viewController: UIViewController!
    let title = "Unable to Show Results"

    let errorMessage = "This may be due to a poor network connection or the real time data is temporarily unavailable, please try again later."

    var nextToArriveWatcher: NextToArriveState_NextToArriveUpdateStatusWatcher?

    var favoriteWatcher: NextToArriveFavorite_NextToArriveUpdateStatusWatcher?

    var hasShowAlertsOnce: Bool = false

    init(viewController: UIViewController) {
        self.viewController = viewController
        let target = store.state.currentTargetForScheduleActions()
        if store.state.currentTargetForScheduleActions() == .nextToArrive {
            nextToArriveWatcher = NextToArriveState_NextToArriveUpdateStatusWatcher()
            nextToArriveWatcher?.delegate = self
        } else if target == .favorites {
            favoriteWatcher = NextToArriveFavorite_NextToArriveUpdateStatusWatcher()
            favoriteWatcher?.delegate = self
        }
    }

    func nextToArriveUpdateStatusUpdated(nextToArriveUpdateStatus: NextToArriveUpdateStatus) {
        guard !hasShowAlertsOnce else { return }
        if nextToArriveUpdateStatus == .dataLoadingError {
            UIAlert.presentOKJumpToSchedulesAlert(viewController: viewController, withTitle: title, message: errorMessage) {
                self.hasShowAlertsOnce = true
            }
        }
        if nextToArriveUpdateStatus == .noResultsReturned {
            UIAlert.presentOKJumpToSchedulesAlert(viewController: viewController, withTitle: title, message: errorMessage) {
                self.hasShowAlertsOnce = true
            }
        }
    }
}
