// Septa. 2017

import Foundation
import UIKit
import ReSwift

class MainNavigationController: UITabBarController, UITabBarControllerDelegate, StoreSubscriber {
    typealias StoreSubscriberStateType = Int?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func filterSubscription(state: AppState) -> Int? {
        return state.navigationState.selectedTab
    }

    override func tabBar(_: UITabBar, didSelect _: UITabBarItem) {
        let action = SwitchTabs(tabBarItemIndex: selectedIndex, description: "Tab Bar was selected by the user")
        store.dispatch(action)
    }

    func newState(state: StoreSubscriberStateType) {
        guard let selectedIndex = state else { return }
        if self.selectedIndex != selectedIndex {
            self.selectedIndex = selectedIndex
        }
    }
}
