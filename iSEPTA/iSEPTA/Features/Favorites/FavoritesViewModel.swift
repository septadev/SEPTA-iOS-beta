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
        case favoriteTripCell
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
        let nib = UINib(nibName: "FavoriteTripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellIds.favoriteTripCell.rawValue)
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

                let headerView: NoConnectionSectionHeader! = stackView.awakeInsertArrangedView(nibName: "NoConnectionSectionHeader")
                favoriteViewModel.configureSectionHeader(firstTripInSection: firstTripInSection, headerView: headerView)

                let firstThreeTrips: ArraySlice<NextToArriveTrip>
                if tripsByRoute.count > 3 {
                    firstThreeTrips = tripsByRoute[0 ... 2]
                } else {
                    firstThreeTrips = tripsByRoute[0 ..< tripsByRoute.count]
                }

                for trip in firstThreeTrips {
                    configureTrip(favoriteViewModel: favoriteViewModel, trip: trip, stackView: stackView)
                }
            } else {
                configureConnectingTrip(favoriteViewModel: favoriteViewModel, trip: firstTripInSection, stackView: stackView)
            }
        }
    }

    func configureTrip(favoriteViewModel: FavoriteNextToArriveViewModel, trip: NextToArriveTrip, stackView: UIStackView) {

        let tripView: TripView! = stackView.awakeInsertArrangedView(nibName: "TripView")
        favoriteViewModel.configureTripView(tripView: tripView, forTrip: trip)
    }

    func configureConnectingTrip(favoriteViewModel: FavoriteNextToArriveViewModel, trip: NextToArriveTrip, stackView: UIStackView) {

        let connectionView: CellConnectionView! = stackView.awakeInsertArrangedView(nibName: "CellConnectionView")
        favoriteViewModel.configureConnectionCell(cell: connectionView, forTrip: trip)
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
