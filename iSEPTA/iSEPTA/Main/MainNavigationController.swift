// Septa. 2017

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

class MainNavigationController: UITabBarController, UITabBarControllerDelegate, StoreSubscriber, FavoritesState_FavoriteToEditWatcherDelegate {

    typealias StoreSubscriberStateType = NavigationController
    var favoritestoEditWatcher: FavoritesState_FavoriteToEditWatcher?
    override func awakeFromNib() {
        super.awakeFromNib()
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
        default: return .schedules
        }
    }

    override var selectedIndex: Int {
        didSet {
            print(selectedIndex)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if store.state.databaseState != .loaded {
                self?.performSegue(withIdentifier: "showDatabaseLoadingModal", sender: self)
            }
        }
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
}
