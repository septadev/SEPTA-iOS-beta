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
        let loadedFavorites = state.filter { $0.nextToArriveUpdateStatus == .dataLoadedSuccessfully }
        favoriteViewModels = loadedFavorites.map { FavoriteNextToArriveViewModel(favorite: $0, delegate: favoriteDelegate) }
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

        let favoriteViewModel = favoriteViewModels[indexPath.section]
        favoriteTripCell.favoriteIcon.image = favoriteViewModel.transitMode().favoritesIcon()
        favoriteTripCell.favoriteNameLabel.text = favoriteViewModel.favorite.favoriteName
        guard let stackView = favoriteTripCell.stackView else { return }
        stackView.clearSubviews()

        // stackView.addArrangedSubview(headerCell.contentView)

        configureTrips(favoriteViewModel: favoriteViewModel, stackView: stackView, indexPath: indexPath)
    }

    func configureTrips(favoriteViewModel: FavoriteNextToArriveViewModel, stackView: UIStackView, indexPath _: IndexPath) {

        for tripsByRoute in favoriteViewModel.groupedTripData {
            guard let firstTripInSection = tripsByRoute.first else { continue }
            if !favoriteViewModel.tripHasConnection(trip: firstTripInSection) {
                let wrapperView = UIView()
                wrapperView.translatesAutoresizingMaskIntoConstraints = false
                let headerView: NoConnectionSectionHeader! = wrapperView.awakeInsertAndPinSubview(nibName: "NoConnectionSectionHeader")
                favoriteViewModel.configureSectionHeader(firstTripInSection: firstTripInSection, headerView: headerView)
                stackView.addArrangedSubview(headerView)

                for trip in tripsByRoute {
                    configureTrip(favoriteViewModel: favoriteViewModel, trip: trip, stackView: stackView)
                }
            } else {
                configureConnectingTrip(favoriteViewModel: favoriteViewModel, trip: firstTripInSection, stackView: stackView)
            }
        }
    }

    func configureTrip(favoriteViewModel: FavoriteNextToArriveViewModel, trip: NextToArriveTrip, stackView: UIStackView) {
        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        let tripView: TripView! = wrapperView.awakeInsertAndPinSubview(nibName: "TripView")
        favoriteViewModel.configureTripView(tripView: tripView, forTrip: trip)
        stackView.addArrangedSubview(wrapperView)
    }

    func configureConnectingTrip(favoriteViewModel: FavoriteNextToArriveViewModel, trip: NextToArriveTrip, stackView: UIStackView) {
        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        let connectionView: CellConnectionView! = wrapperView.awakeInsertAndPinSubview(nibName: "CellConnectionView")
        favoriteViewModel.configureConnectionCell(cell: connectionView, forTrip: trip)
        stackView.addArrangedSubview(wrapperView)
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
