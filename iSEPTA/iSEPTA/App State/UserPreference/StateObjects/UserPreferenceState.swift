// Septa. 2017

import Foundation
import SeptaSchedule

struct UserPreferenceState {
    let defaultsLoaded: Bool
    let startupTransitMode: TransitMode
    let startupNavigationController: NavigationController
    let databaseVersion: Int

    init(defaultsLoaded: Bool = false, startupTransitMode: TransitMode = .bus, startupNavigationController: NavigationController = .nextToArrive, databaseVersion: Int = 0) {
        self.defaultsLoaded = defaultsLoaded
        self.startupTransitMode = startupTransitMode
        self.startupNavigationController = startupNavigationController
        self.databaseVersion = databaseVersion
    }
}

extension UserPreferenceState: Equatable {}
func ==(lhs: UserPreferenceState, rhs: UserPreferenceState) -> Bool {
    var areEqual = true

    areEqual = lhs.defaultsLoaded == rhs.defaultsLoaded
    guard areEqual else { return false }

    areEqual = lhs.startupTransitMode == rhs.startupTransitMode
    guard areEqual else { return false }

    areEqual = lhs.startupNavigationController == rhs.startupNavigationController
    guard areEqual else { return false }

    areEqual = lhs.databaseVersion == rhs.databaseVersion
    guard areEqual else { return false }

    return areEqual
}
