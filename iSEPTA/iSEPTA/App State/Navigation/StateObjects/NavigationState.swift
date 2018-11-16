// Septa. 2017

import Foundation
import SeptaSchedule

typealias AppStackState = [NavigationController: NavigationStackState]

struct NavigationState: Equatable {
    var appStackState: AppStackState = [NavigationController: NavigationStackState]()
    var activeNavigationController: NavigationController = .nextToArrive
    var alertsToDisplay: [AppAlert] = [AppAlert]()

    var nextAlertToDisplay: AppAlert? { return alertsToDisplay.first }
}
