// Septa. 2017

import Foundation
import ReSwift

protocol NavigationAction: Action {}

struct InitialNavigationState: NavigationAction {

    let state: NavigationState
}

struct InitialNavigationStackState: NavigationAction {

    let state: NavigationStackState
}
