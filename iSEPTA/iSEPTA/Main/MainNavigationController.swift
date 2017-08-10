// Septa. 2017

import Foundation
import UIKit
import ReSwift

class MainNavigationController: UITabBarController, StoreSubscriber {
    typealias StoreSubscriberStateType = NavigationState

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func filterSubscription(state: AppState) -> NavigationState {
        return state.navigationState
    }

    func newState(state _: StoreSubscriberStateType) {
        //        guard let selectedFeature = state.selectedFeature else { return }
        //        if let activeFeature = state.activeFeature, selectedFeature == activeFeature {
        //            return
        //        }
        //        switch selectedFeature {
        //        case .schedules:
        //            let schedules = viewControllers?.filter { viewController in
        //                if viewController is SchedulesNavigationController {
        //                    return true
        //                } else {
        //                    return false
        //                }
        //            }.first
        //            selectedViewController = schedules
        //        default:
        //            print("")
        //        }
    }
}
