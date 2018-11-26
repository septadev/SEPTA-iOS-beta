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
    var databaseUpdateWatcher: DatabaseUpdateWatcher?
    var databaseDownloadedWatcher: DatabaseDownloadedWatcher?
    var pushNotificationTripDetailState_ResultsWatcher = PushNotificationTripDetailState_ResultsWatcher()
    var doNotShowThisAlertAgainWatcher: UserPreferenceState_DoNotShowThisAlertAgainWatcher?

    var currentlyPresentingPushNotificationTripDetail = false

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        favoritestoEditWatcher = FavoritesState_FavoriteToEditWatcher(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
    }

    @objc func applicationWillResignActive(notification _: Any) {
        dismissPushNotificationTripDetailIfNecessary()
        currentlyPresentingPushNotificationTripDetail = false
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
            if store.state.databaseState == .loading {
                self?.performSegue(withIdentifier: "showDatabaseLoadingModal", sender: self)
            }
        }
        
        doNotShowThisAlertAgainWatcher = UserPreferenceState_DoNotShowThisAlertAgainWatcher()
        doNotShowThisAlertAgainWatcher?.delegate = self

        genericAlertsWatcher = AlertState_HasGenericOrAppAlertsWatcher()
        genericAlertsWatcher?.delegate = self

        modalAlertsDisplayedWatcher = AlertState_ModalAlertsDisplayedWatcher()
        modalAlertsDisplayedWatcher?.delegate = self

        if databaseUpdateWatcher == nil {
            databaseUpdateWatcher = DatabaseUpdateWatcher(delegate: self)
        }
        if databaseDownloadedWatcher == nil {
            databaseDownloadedWatcher = DatabaseDownloadedWatcher(delegate: self)
        }

        pushNotificationTripDetailState_ResultsWatcher.delegate = self
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
        guard store.state.databaseState == .loaded else { return }
        let alertState = store.state.alertState
        let doNotShowThisAlertAgainState = store.state.preferenceState.doNotShowThisAlertAgain
        let lastSavedDoNotShowThisAlertAgainState = store.state.preferenceState.lastSavedDoNotShowThisAlertAgainState

        if alertState.hasGenericAlerts && alertState.hasAppAlerts && !modalAlertsDisplayed && !doNotShowThisAlertAgainState {
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
        } else if alertState.hasGenericAlerts && !modalAlertsDisplayed && !doNotShowThisAlertAgainState {
            let message = AlertDetailsViewModel.renderMessage(alertDetails: alertState.genericAlertDetails) { return $0.message }
            if let message = message {
                UIAlert.presentAttributedOKAlertFrom(viewController: self, withTitle: "General SEPTA Alert", attributedString: message) {
                    let action = ResetModalAlertsDisplayed(modalAlertsDisplayed: true)
                    store.dispatch(action)
                }
            }
        } else if alertState.hasAppAlerts && !modalAlertsDisplayed && !doNotShowThisAlertAgainState {
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

extension MainNavigationController: DatabaseUpdateWatcherDelegate {
    func databaseUpdateAvailable() {
        let alert = UIAlertController(title: "There are new schedules available", message: "Would you like to download them now?", preferredStyle: .alert)
        let downloadAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            store.dispatch(DownloadDatabaseUpdate())
        })
        let laterAction = UIAlertAction(title: "Remind me later", style: .default, handler: { _ in
            let dbFileManager = DatabaseFileManager()
            dbFileManager.setDatabaseUpdateInProgress(inProgress: false)
            store.dispatch(DatabaseUpToDate())
        })
        alert.addAction(downloadAction)
        alert.addAction(laterAction)
        alert.show()
    }
}

extension MainNavigationController: DatabaseDownloadedWatcherDelegate {
    func databaseDownloadComplete() {
        let alert = UIAlertController(title: "Schedule download complete", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.show()
        let dbFileManager = DatabaseFileManager()
        dbFileManager.setDatabaseUpdateInProgress(inProgress: false)
        store.dispatch(DatabaseUpToDate())
    }
}

extension MainNavigationController: PushNotificationTripDetailState_ResultsDelegateDelegate {
    func pushNotificationTripDetailState_Updated(state: PushNotificationTripDetailState) {
        if state.shouldDisplayPushNotificationTripDetail && !currentlyPresentingPushNotificationTripDetail {
            let viewController: UIViewController = ViewController.pushNotificationTripDetailNavigationController.instantiateViewController()
            present(viewController, animated: true, completion: nil)
            currentlyPresentingPushNotificationTripDetail = true
        } else if !state.shouldDisplayPushNotificationTripDetail && currentlyPresentingPushNotificationTripDetail {
            dismiss(animated: true, completion: nil)
            currentlyPresentingPushNotificationTripDetail = false
        } else if state.shouldDisplayExpiredNotification {
            guard let message = buildExpiredMessage(delayNotification: state.delayNotification) else { return }
            dismissPushNotificationTripDetailIfNecessary()
            UIAlert.presentOKAlertFrom(viewController: self, withTitle: "Push Notification", message: message) {
                store.dispatch(ClearPushNotificationTripDetailData())
            }
        } else if state.shouldDisplayNetWorkError {
            guard let message = buildPushNotificationNetworkErrorMessage(delayNotification: state.delayNotification) else { return }
            dismissPushNotificationTripDetailIfNecessary()
            UIAlert.presentOKAlertFrom(viewController: self, withTitle: "Push Notification", message: message) {
                store.dispatch(ClearPushNotificationTripDetailData())
            }
        }
//        guard let tripId = state.tripId else { return }
//        if !currentlyPresentingPushNotificationTripDetail {
//                let viewController: JsonDetailViewController = ViewController.jsonDetailViewController.instantiateViewController()!
//                viewController.displayEncodable(encodable: state)
//                currentlyPresentingPushNotificationTripDetail = true
//                present(viewController, animated: true, completion: nil)
//            } else {
//                let viewController = self.presentedViewController as! JsonDetailViewController
//                viewController.displayEncodable(encodable: state)
//            }
    }

    func dismissPushNotificationTripDetailIfNecessary() {
        if currentlyPresentingPushNotificationTripDetail {
            dismiss(animated: true, completion: nil)
            currentlyPresentingPushNotificationTripDetail = false
            store.dispatch(ClearPushNotificationTripDetailData())
        }
    }

    func buildExpiredMessage(delayNotification: SeptaDelayNotification?) -> String? {
        guard let delayNotification = delayNotification else { return nil }

        return "Train Delay Notification on \(delayNotification.routeId) Train #\(delayNotification.vehicleId) is now expired."
    }

    func buildPushNotificationNetworkErrorMessage(delayNotification: SeptaDelayNotification?) -> String? {
        guard let delayNotification = delayNotification else { return nil }

        return "We were unable to retrieve the detail on the \(delayNotification.routeId) delay notification."
    }
}

extension MainNavigationController: UserPreferenceState_DoNotShowThisAlertAgainWatcherDelegate {
    
    func userPreferenceState_DoNotShowThisAlertAgainUpdated(doNotShowThisAlertAgainWatcher: Bool) {
        // TODO: JJ 8
        //let action = DoNotShowThisAlertAgain(lastSavedDoNotShowThisAlertAgainState: lastSavedDoNotShowThisAlertAgainState, doNotShowThisAlertAgain: doNotShowThisAlertAgainWatcher)
        //store.dispatch(action)
    }

}
