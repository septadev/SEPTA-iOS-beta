// Septa. 2017

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

class MainNavigationController: UITabBarController, UITabBarControllerDelegate, StoreSubscriber {
    typealias StoreSubscriberStateType = Int?
    let databaseFileManager = DatabaseFileManager()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        store.subscribe(self) {
            $0.select {
                $0.navigationState.selectedTab
            }
        }
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

    override func viewDidLoad() {

        super.viewDidLoad()
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

    func displayAlert(_ message: String) {

        UIAlert.presentOKAlertFrom(viewController: self,
                                   withTitle: "SEPTA Beta Testers!",
                                   message: message,
                                   completion: nil)
    }
}
