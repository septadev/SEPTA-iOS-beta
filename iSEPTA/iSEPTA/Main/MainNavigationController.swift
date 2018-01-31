// Septa. 2017

import Foundation
import ReSwift
import SeptaRest
import SeptaSchedule
import UIKit

class MainNavigationController: UITabBarController, UITabBarControllerDelegate, StoreSubscriber, FavoritesState_FavoriteToEditWatcherDelegate, AlertState_HasGenericOrAppAlertsWatcherDelegate, AlertState_ModalAlertsDisplayedWatcherDelegate {

    typealias StoreSubscriberStateType = NavigationController
    var favoritestoEditWatcher: FavoritesState_FavoriteToEditWatcher?
    var genericAlertsWatcher: AlertState_HasGenericOrAppAlertsWatcher?
    var modalAlertsDisplayedWatcher: AlertState_ModalAlertsDisplayedWatcher?

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        favoritestoEditWatcher = FavoritesState_FavoriteToEditWatcher(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        store.subscribe(self) {
            $0.select {
                $0.navigationState.activeNavigationController
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        selectedIndex = state.tabIndex()
    }

    override func tabBar(_: UITabBar, didSelect item: UITabBarItem) {
        guard let newIndex = tabBar.items?.index(of: item) else { return }

        let targetNavController = navigationControllerFromTabIndex(newIndex)
        let action = SwitchTabs(activeNavigationController: targetNavController, description: "Tab Bar was selected by the user")
        store.dispatch(action)
    }

    func navigationControllerFromTabIndex(_ index: Int) -> NavigationController {
        switch index {
        case 0: return .nextToArrive
        case 1: return .favorites
        case 2: return .alerts
        case 3: return .schedules
        case 4: return .more
        default: return .schedules
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if store.state.databaseState != .loaded {
                self?.performSegue(withIdentifier: "showDatabaseLoadingModal", sender: self)
            }
        }

        genericAlertsWatcher = AlertState_HasGenericOrAppAlertsWatcher()
        genericAlertsWatcher?.delegate = self

        modalAlertsDisplayedWatcher = AlertState_ModalAlertsDisplayedWatcher()
        modalAlertsDisplayedWatcher?.delegate = self
    }

    var modalTransitioningDelegate: UIViewControllerTransitioningDelegate!
    func presentEditFavoritModal() {

        modalTransitioningDelegate = ViewController.editFavoriteViewController.transitioningDelegate()
        if let viewController: UIViewController = ViewController.editFavoriteViewController.instantiateViewController() {
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = modalTransitioningDelegate
            present(viewController, animated: true, completion: nil)
        }
    }

    func favoritesState_FavoriteToEditUpdated(favorite: Favorite?) {
        if let _ = favorite, presentedViewController == nil {
            presentEditFavoritModal()
        } else if let _ = presentedViewController, favorite == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    func alertState_HasGenericOrAppAlertsUpdated(bool hasAlerts: Bool) {
        guard let alertsTabBarItem = self.tabBar.items?[2] else { return }
        alertsTabBarItem.badgeValue = hasAlerts ? "!" : nil
    }

    func alertState_ModalAlertsDisplayedUpdated(modalAlertsDisplayed: Bool) {
        let alertState = store.state.alertState

        if alertState.hasGenericAlerts && alertState.hasAppAlerts && !modalAlertsDisplayed {
            guard let genericMessage = AlertDetailsViewModel.renderMessage(alertDetails: alertState.genericAlertDetails, filter: { $0.message }),
                let appAlertMessage = AlertDetailsViewModel.renderMessage(alertDetails: alertState.appAlertDetails, filter: { $0.message })
            else { return }
            let space = NSAttributedString(string: " \n")
            let genericMessageTitle = NSAttributedString(string: "General SEPTA Alert: ")
            let appAlertMessageTitle = NSAttributedString(string: "Mobile App Alert: ")
            let genericPlusAppAlertsMessage = NSMutableAttributedString()
            genericPlusAppAlertsMessage.append(genericMessageTitle)
            genericPlusAppAlertsMessage.append(genericMessage)
            genericPlusAppAlertsMessage.append(space)
            genericPlusAppAlertsMessage.append(appAlertMessageTitle)
            genericPlusAppAlertsMessage.append(appAlertMessage)
            genericPlusAppAlertsMessage.append(space)

            UIAlert.presentAttributedOKAlertFrom(viewController: self, withTitle: "SEPTA Alert", attributedString: genericPlusAppAlertsMessage) {
                let action = ResetModalAlertsDisplayed(modalAlertsDisplayed: true)
                store.dispatch(action)
            }
        } else if alertState.hasGenericAlerts && !modalAlertsDisplayed {
            let message = AlertDetailsViewModel.renderMessage(alertDetails: alertState.genericAlertDetails) { return $0.message }
            if let message = message {
                UIAlert.presentAttributedOKAlertFrom(viewController: self, withTitle: "General SEPTA Alert", attributedString: message) {
                    let action = ResetModalAlertsDisplayed(modalAlertsDisplayed: true)
                    store.dispatch(action)
                }
            }
        } else if alertState.hasAppAlerts && !modalAlertsDisplayed {
            let message = AlertDetailsViewModel.renderMessage(alertDetails: alertState.appAlertDetails) { return $0.message }
            if let message = message {
                UIAlert.presentAttributedOKAlertFrom(viewController: self, withTitle: "Mobile App Alert", attributedString: message) {
                    let action = ResetModalAlertsDisplayed(modalAlertsDisplayed: true)
                    store.dispatch(action)
                }
            }
        }
    }
}
