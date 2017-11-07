//
//  FavoritesViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: UIViewController, IdentifiableController {
    let viewController: ViewController = .favoritesViewController

    @IBOutlet weak var tableView: UITableView!
    var timer: Timer?
    var viewModel: FavoritesViewModel!
    private var pendingRequestWorkItem: DispatchWorkItem?

    var millisecondsToDelayTableReload = 100

    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.navBarBlue
        viewModel = FavoritesViewModel(delegate: self, tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.allowsSelection = false
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 18))
        footerView.backgroundColor = UIColor.clear
        tableView.tableFooterView = footerView
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(navigateToNextToArrive))
    }

    @objc func navigateToNextToArrive() {
        let stackState = NavigationStackState(viewControllers: [.nextToArriveController], modalViewController: nil)

        let viewStackAction = InitializeNavigationState(navigationController: .nextToArrive, navigationStackState: stackState, description: "Setting Navigation Stack State prior to moving from favorites to Next To Arrive")
        store.dispatch(viewStackAction)

        let action = SwitchTabs(activeNavigationController: .nextToArrive, description: "Jumping to Next To Arrive From Favorites")
        store.dispatch(action)
    }
}

extension FavoritesViewController { // refresh timer
    override func viewDidAppear(_: Bool) {
        initTimer()
        refreshNextToArriveForAllFavorites()
    }

    override func viewWillAppear(_: Bool) {
        viewModel.subscribe()
        tableView.contentOffset = CGPoint(x: 0, y: 0)
    }

    override func viewWillDisappear(_: Bool) {
        timer?.invalidate()
        viewModel.unsubscribe()
    }

    func initTimer() {
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(oneMinuteTimerFired(timer:)), userInfo: nil, repeats: true)
    }

    @objc func oneMinuteTimerFired(timer _: Timer) {
        millisecondsToDelayTableReload = 4000
        refreshNextToArriveForAllFavorites()
    }

    public func refreshNextToArriveForAllFavorites() {
        let _: [Favorite] = store.state.favoritesState.favorites.filter({ $0.nextToArriveUpdateStatus != .dataLoading }).map {
            var favorite = $0
            favorite.refreshDataRequested = true
            let action = RequestFavoriteNextToArriveUpdate(favorite: favorite, description: "Timer based request to update this favorite")
            store.dispatch(action)
            return favorite
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 0
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 18))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tripCell = tableView.dequeueReusableCell(withIdentifier: "favoriteTripCell") as? FavoriteTripCell else { return UITableViewCell() }
        viewModel.configureTripCell(favoriteTripCell: tripCell, indexPath: indexPath)

        return tripCell
    }
}

extension FavoritesViewController: UpdateableFromViewModel {

    func viewModelUpdated() {
        pendingRequestWorkItem?.cancel()

        // Wrap our request in a work item
        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self, let tableView = strongSelf.tableView else { return }

            tableView.reloadData()
            tableView.layoutIfNeeded()
        }

        // Save the new work item and execute it after 250 ms
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(millisecondsToDelayTableReload), execute: requestWorkItem)
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }
}
