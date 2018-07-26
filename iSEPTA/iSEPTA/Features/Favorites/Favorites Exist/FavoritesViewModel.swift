//
//  FavoritesViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class FavoritesViewModel: StoreSubscriber, SubscriberUnsubscriber {
    typealias StoreSubscriberStateType = Set<Favorite>

    enum CellIds: String {
        case favoriteTripCell
        case favoriteTransitViewCell
    }

    let delegate: UpdateableFromViewModel
    let tableView: UITableView!
    let favoriteDelegate = FavoritesViewModelDelegate()
    var collapseForEditMode = false

    init(delegate: UpdateableFromViewModel = FavoritesViewModelDelegate(), tableView: UITableView) {
        self.delegate = delegate
        self.tableView = tableView
        self.tableView.backgroundColor = UIColor.clear
        registerViews(tableView: tableView)
    }

    func registerViews(tableView: UITableView) {
        let favTripNib = UINib(nibName: "FavoriteTripCell", bundle: nil)
        tableView.register(favTripNib, forCellReuseIdentifier: CellIds.favoriteTripCell.rawValue)
        let favTransitViewNib = UINib(nibName: "FavoriteTransitViewCell", bundle: nil)
        tableView.register(favTransitViewNib, forCellReuseIdentifier: CellIds.favoriteTransitViewCell.rawValue)
    }

    var favoriteViewModels = [FavoriteNextToArriveViewModel]()

    func newState(state: StoreSubscriberStateType) {
        let favoritesToDisplay = Array(state)

        favoriteViewModels = favoritesToDisplay.map { FavoriteNextToArriveViewModel(favorite: $0, delegate: favoriteDelegate) }
        favoriteViewModels.sort { $0.favorite.sortOrder < $1.favorite.sortOrder }

        delegate.viewModelUpdated()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState.favoritesToDisplay
            }.skipRepeats({ (_, _) -> Bool in
                false
            })
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

    func configureNtaTripCell(favoriteTripCell: FavoriteTripCell, indexPath: IndexPath) {
        let favoriteViewModel = favoriteViewModels[indexPath.section]
        favoriteTripCell.favoriteIcon.image = favoriteViewModel.transitMode().favoritesIcon()
        favoriteTripCell.favoriteIcon.accessibilityLabel = favoriteViewModel.favorite.transitMode.favoriteName()
        favoriteTripCell.favoriteNameLabel.text = favoriteViewModel.favorite.favoriteName
        favoriteTripCell.currentFavorite = favoriteViewModel.favorite
        favoriteTripCell.configureBasedOnScheduleAvailability(scheduleDataAvailable: favoriteViewModel.ntaUnavailable())
        guard let stackView = favoriteTripCell.stackView else { return }
        stackView.clearSubviews()
        stackView.accessibilityLabel = "Upcoming Trips"

        if favoriteViewModel.favorite.sortOrder == Favorite.defaultSortOrder {
            // favorite has default sort order, update it to current position
            favoriteViewModel.favorite.sortOrder = indexPath.section
            store.dispatch(SaveFavorite(favorite: favoriteViewModel.favorite))
        }
        if !favoriteViewModel.favorite.collapsed && !collapseForEditMode {
            configureTrips(favoriteViewModel: favoriteViewModel, stackView: stackView, indexPath: indexPath)
        }
    }

    func configureTransitViewCell(cell: FavoriteTransitViewCell, indexPath: IndexPath) {
        let viewModel = favoriteViewModels[indexPath.section]
        cell.favorite = viewModel.favorite
        cell.titleLabel.text = viewModel.favorite.favoriteName
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
        tripView.isInteractive = false
        tripView.setNeedsDisplay()
        favoriteViewModel.configureTripView(tripView: tripView, forTrip: trip)
    }

    func configureConnectingTrip(favoriteViewModel: FavoriteNextToArriveViewModel, trip: NextToArriveTrip, stackView: UIStackView) {
        let connectionView: CellConnectionView! = stackView.awakeInsertArrangedView(nibName: "CellConnectionView")
        favoriteViewModel.configureConnectionCell(cell: connectionView, forTrip: trip)
    }

    func favorite(at indexPath: IndexPath) -> Favorite {
        return favoriteViewModel(at: indexPath).favorite
    }

    func favoriteViewModel(at indexPath: IndexPath) -> FavoriteNextToArriveViewModel {
        return favoriteViewModels[indexPath.section]
    }

    func moveFavorite(from source: IndexPath, to destination: IndexPath) {
        var evicted = false // Has the favorite previously in the destination spot been moved out
        var movedIn = false // Has the favorite being moved been placed in it's new spot
        let movingUp = source.section > destination.section // Are favorites being pushed up or down?

        // Loop through all favorites and figure it's new spot
        for (index, fvm) in favoriteViewModels.enumerated() {
            if index == destination.section {
                // This favorite is in the spot where the moved favorite is going. Push it up or down
                fvm.favorite.sortOrder = destination.section + (movingUp ? 1 : -1)
                evicted = true
            } else if index == source.section {
                // This is the favorite being moved
                fvm.favorite.sortOrder = destination.section
                movedIn = true
            } else if (movingUp && evicted && !movedIn) || (!movingUp && movedIn && !evicted) {
                // This is a favorite that is affected by the move
                fvm.favorite.sortOrder = index + (movingUp ? 1 : -1)
            } else {
                // This favorite wasn't affected but let's make sure it's order is correct
                fvm.favorite.sortOrder = index
            }
            // Favorite has it's new place, save it.
            store.dispatch(SaveFavorite(favorite: fvm.favorite))
        }
    }

    func remove(favorite: Favorite) {
        let action = RemoveFavorite(favorite: favorite)
        store.dispatch(action)
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
