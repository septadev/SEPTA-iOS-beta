//
//  NextToArriveDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveDetailViewController: UIViewController, IdentifiableController, UIGestureRecognizerDelegate, FavoriteState_NextToArriveFavoriteWatcherDelegate {
    let viewController: ViewController = .nextToArriveDetailController
    var nextToArriveFavoriteWatcher: FavoriteState_NextToArriveFavoriteWatcher?
    @IBOutlet var infoViewHeightCollapsedConstraint: NSLayoutConstraint!
    @IBOutlet var nextToArriveInfoTableScrollableToggle: ScrollableTableViewToggle!
    @IBOutlet var infoViewHeightExpandedConstraint: NSLayoutConstraint!

    var nextToArriveFavoritesController: NextToArriveFavoritesIconController!
    @IBOutlet weak var editFavoriteBarButtonItem: UIBarButtonItem!
    weak var infoHeaderView: UIView?
    @IBOutlet weak var createFavoriteBarButtonItem: UIBarButtonItem!

    @IBOutlet var upSwipeGestureRecognizer: UISwipeGestureRecognizer! {
        didSet {
            upSwipeGestureRecognizer.addTarget(self, action: #selector(NextToArriveDetailViewController.swipeAction(_:)))
        }
    }

    @IBOutlet var downSwipeGestureRecognizer: UISwipeGestureRecognizer! {
        didSet {
            downSwipeGestureRecognizer.addTarget(self, action: #selector(NextToArriveDetailViewController.swipeAction(_:)))
        }
    }

    @IBOutlet weak var tripView: UIView!

    var constraintsToggle: ConstraintsToggle!
    var gestureRecognizerToggle: SwipeGestureRecognizerToggle!

    var errorWatcher: NextToArriveNoResultsAlert?

    override func viewDidLoad() {
        navigationController?.navigationBar.configureBackButton()
        view.backgroundColor = SeptaColor.navBarBlue

        view.bringSubview(toFront: tripView)
        constraintsToggle = ConstraintsToggle(activeConstraint: infoViewHeightCollapsedConstraint, inactiveConstraint: infoViewHeightExpandedConstraint)
        gestureRecognizerToggle = SwipeGestureRecognizerToggle(activeRecognizer: upSwipeGestureRecognizer, inactiveRecognizer: downSwipeGestureRecognizer)
        configureFavoriteController()
        configureNavigationItemTitle()

        configureScrollableTableView()
        errorWatcher = NextToArriveNoResultsAlert(viewController: self)
    }

    func configureScrollableTableView() {

        guard let tableView = nextToArriveInfoViewController?.tableView else { return }
        nextToArriveInfoTableScrollableToggle = ScrollableTableViewToggle()
        nextToArriveInfoTableScrollableToggle.tableView = tableView
        nextToArriveInfoTableScrollableToggle.shouldScroll = false
    }

    func configureNavigationItemTitle() {
        if store.state.targetForScheduleActions() == .favorites {
            nextToArriveFavoriteWatcher = FavoriteState_NextToArriveFavoriteWatcher()
            nextToArriveFavoriteWatcher?.delegate = self
        } else {
            navigationItem.title = store.state.nextToArriveState.scheduleState.scheduleRequest.transitMode.nextToArriveDetailTitle()
        }
    }

    func favoriteState_NextToArriveFavoriteUpdated(favorite: Favorite?) {
        if let favorite = favorite {
            navigationItem.title = favorite.favoriteName
        }
    }

    func configureFavoriteController() {
        nextToArriveFavoritesController = NextToArriveFavoritesIconController()
        nextToArriveFavoritesController.createFavoriteBarButtonItem = createFavoriteBarButtonItem
        nextToArriveFavoritesController.editFavoriteBarButtonItem = editFavoriteBarButtonItem
        nextToArriveFavoritesController.navigationItem = navigationItem
        nextToArriveFavoritesController.setUpTargets()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        backButtonPopped(toParentViewController: parent)
    }

    @objc func toggleMapHeight() {
        constraintsToggle = constraintsToggle.toggleConstraints(inView: view)
        gestureRecognizerToggle = gestureRecognizerToggle.toggleRecognizers()
        nextToArriveInfoTableScrollableToggle.toggleTableViewScrolling()
        nextToArriveInfoViewController?.updateSliderAccessibility()
    }

    weak var nextToArriveInfoViewController: NextToArriveInfoViewController?

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard let infoViewController = segue.destination as? NextToArriveInfoViewController else { return }
        self.nextToArriveInfoViewController = infoViewController
        infoViewController.nextToArriveDetailViewController = self
    }

    @IBAction func swipeAction(_: UISwipeGestureRecognizer) {

        toggleMapHeight()
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        print("Asking should receive touch")
        return true
    }

    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return true
    }
}
