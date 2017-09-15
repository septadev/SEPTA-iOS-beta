//
//  FavoritesViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var timer: Timer?
    var viewModel: FavoritesViewModel!

    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.navBarBlue
        viewModel = FavoritesViewModel(delegate: self, tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 18))
        footerView.backgroundColor = UIColor.clear
        tableView.tableFooterView = footerView
    }
}

extension FavoritesViewController { // refresh timer
    override func viewDidAppear(_: Bool) {
        initTimer()
    }

    override func viewWillDisappear(_: Bool) {
        timer?.invalidate()
    }

    func initTimer() {
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(oneMinuteTimerFired(timer:)), userInfo: nil, repeats: true)
    }

    @objc func oneMinuteTimerFired(timer _: Timer) {

        let _: [Favorite] = store.state.favoritesState.favorites.filter({ $0.nextToArriveUpdateStatus == .dataLoadedSuccessfully }).map {
            var favorite = $0
            favorite.refreshDataRequested = true
            let action = UpdateFavorite(favorite: favorite, description: "Timer based request to update this favorite")
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
        return 10
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
        tableView.reloadData()
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }
}
