// Septa. 2017

import Foundation
import ReSwift

struct AppState: StateType {
    let navigationState: NavigationState

    public init(navigationState: NavigationState) {
        self.navigationState = navigationState
    }
}

extension AppState: Equatable {}
func ==(lhs: AppState, rhs: AppState) -> Bool {
    var areEqual = true

    if lhs.navigationState == rhs.navigationState {
        areEqual = true
    } else {
        return false
    }
    return areEqual
}
