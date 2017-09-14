//
//  FavoritesViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

class FavoritesViewModel: StoreSubscriber, SubscriberUnsubscriber {

    typealias StoreSubscriberStateType = [Favorite]

    enum CellIds: String {
        case noConnectionCell
        case connectionCell
        case noConnectionSectionHeader
    }

    let delegate: UpdateableFromViewModel
    let tableView: UITableView!
    let favoriteDelegate = FavoritesViewModelDelegate()

    init(delegate: UpdateableFromViewModel = FavoritesViewModelDelegate(), tableView: UITableView) {
        self.delegate = delegate
        self.tableView = tableView
        self.tableView.backgroundColor = UIColor.clear
        registerViews(tableView: tableView)
        subscribe()
    }

    func registerViews(tableView: UITableView) {
        tableView.register(UINib(nibName: "NoConnectionCell", bundle: nil), forCellReuseIdentifier: CellIds.noConnectionCell.rawValue)
        tableView.register(UINib(nibName: "ConnectionCell", bundle: nil), forCellReuseIdentifier: CellIds.connectionCell.rawValue)
        tableView.register(NoConnectionUIHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellIds.noConnectionSectionHeader.rawValue)
    }

    var favoriteViewModels = [FavoriteNextToArriveViewModel]()

    func newState(state: StoreSubscriberStateType) {
        favoriteViewModels = state.map { FavoriteNextToArriveViewModel(favorite: $0, delegate: favoriteDelegate) }
        favoriteViewModels.sort { $0.favorite.favoriteName < $1.favorite.favoriteName }
        delegate.viewModelUpdated()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState.favorites
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}

extension FavoritesViewModel { // table loading

    func numberOfRows() -> Int {

        return favoriteViewModels.count
    }

    func configureTripCell(favoriteTripCell: FavoriteTripCell, indexPath: IndexPath) {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "favoriteHeaderCell", for: indexPath) as? FavoriteHeaderCell else { return }
        let favoriteViewModel = favoriteViewModels[indexPath.section]
        headerCell.favoriteIcon.image = favoriteViewModel.transitMode().favoritesIcon()
        headerCell.favoriteName.text = favoriteViewModel.favorite.favoriteName
        favoriteTripCell.stackView.clearSubviews()
        favoriteTripCell.stackView.addArrangedSubview(headerCell.contentView)
    }
}

class FavoritesViewModelDelegate: UpdateableFromViewModel {
    func viewModelUpdated() {
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }
}
