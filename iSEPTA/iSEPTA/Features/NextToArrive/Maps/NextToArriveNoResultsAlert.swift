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

    let errorMessage = "An error has occurred. Please try your request again. If this error continues, please contact SEPTA to let us know."

    let noResultsMessage = "No Next to Arrive results were returned.  The system may be down temporarily.  If this continues, please contact SEPTA to let us know."

    var nextToArriveWatcher: NextToArriveState_NextToArriveUpdateStatusWatcher?

    var favoriteWatcher: NextToArriveFavorite_NextToArriveUpdateStatusWatcher?

    init(viewController: UIViewController) {
        self.viewController = viewController
        let target = store.state.targetForScheduleActions()
        if store.state.targetForScheduleActions() == .nextToArrive {
            nextToArriveWatcher = NextToArriveState_NextToArriveUpdateStatusWatcher()
            nextToArriveWatcher?.delegate = self
        } else if target == .favorites {
            favoriteWatcher = NextToArriveFavorite_NextToArriveUpdateStatusWatcher()
            favoriteWatcher?.delegate = self
        }
    }

    func nextToArriveUpdateStatusUpdated(nextToArriveUpdateStatus: NextToArriveUpdateStatus) {
        guard let controller = viewController as? IdentifiableController else { return }
        if nextToArriveUpdateStatus == .dataLoadingError {
            UIAlert.presentOKAlertFrom(viewController: viewController, withTitle: title, message: errorMessage) {
                let popAction = PopViewController(viewController: controller.viewController, description: "Popping because no NTA results retrieved")
                store.dispatch(popAction)
            }
        }
        if nextToArriveUpdateStatus == .noResultsReturned {
            UIAlert.presentOKAlertFrom(viewController: viewController, withTitle: title, message: noResultsMessage) {
                let popAction = PopViewController(viewController: controller.viewController, description: "Popping because no NTA results retrieved")
                store.dispatch(popAction)
            }
        }
    }
}
