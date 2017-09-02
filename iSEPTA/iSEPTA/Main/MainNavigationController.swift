// Septa. 2017

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

class MainNavigationController: UITabBarController, UITabBarControllerDelegate, StoreSubscriber {

    typealias StoreSubscriberStateType = NavigationController
    let databaseFileManager = DatabaseFileManager()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        store.subscribe(self) {
            $0.select {
                $0.navigationState.selectedTab
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        selectedIndex = state.tabIndex()
    }

    override func tabBar(_: UITabBar, didSelect item: UITabBarItem) {
        guard let newIndex = tabBar.items?.index(of: item) else { return }

        let targetNavController = navigationControllerFromTabIndex(newIndex)
        let action = SwitchTabs(tabBarItemIndex: targetNavController, description: "Tab Bar was selected by the user")
        store.dispatch(action)
    }

    func navigationControllerFromTabIndex(_ index: Int) -> NavigationController {
        switch index {
        case 0: return .nextToArrive
        case 1: return .favorites
        case 2: return .alerts
        case 3: return .schedules
        default: return .schedules
        }
    }

    override var selectedIndex: Int {
        didSet {
            print(selectedIndex)
        }
    }

    func displayAlert(_ message: String) {

        UIAlert.presentOKAlertFrom(viewController: self,
                                   withTitle: "SEPTA Beta Testers!",
                                   message: message,
                                   completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        movePreloadedDatabaseIfNeeded()
    }

    func movePreloadedDatabaseIfNeeded() {

        databaseFileManager.unzipFileToDocumentsDirectoryIfNecessary(
            startCompletion: { [weak self] message in
                self?.displayAlert(message) },
            endCompletion: { [weak self] message in
                self?.dismiss(animated: true, completion: nil)
                let action = DatabaseLoaded()
                store.dispatch(action)
                self?.displayAlert(message)

        })
    }
}
