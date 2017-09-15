//
//  FavoritesNextToArriveProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule
import ReSwift
import CoreLocation

class FavoritesNextToArriveProvider: StoreSubscriber {

    typealias StoreSubscriberStateType = [Favorite]

    let mapper = NextToArriveMapper()

    static let sharedInstance = FavoritesNextToArriveProvider()

    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    let scheduleRequestWatcher = NextToArriveScheduleRequestWatcher()

    private init() {
        subscribe()
    }

    deinit {
        unsubscribe()
    }

    func newState(state: [Favorite]) {
        let favoritesToUpdate = state
        retrieveNextToArrive(favorites: favoritesToUpdate)
    }

    func retrieveNextToArrive(favorites: [Favorite]) {
        for favorite in favorites {
            retrieveNextToArrive(favorite: favorite, completion: mapArrivals)
        }
    }

    func reportSuccessfullyUpdatedFavorite(favorite: Favorite, nextToArriveTrips: [NextToArriveTrip]) {
        var favorite = favorite
        favorite.nextToArriveTrips = nextToArriveTrips
        favorite.nextToArriveUpdateStatus = .dataLoadedSuccessfully
        favorite.refreshDataRequested = false
        let updateAction = UpdateFavorite(favorite: favorite, description: "Updating favorite \(favorite.favoriteId) next to arrive")
        store.dispatch(updateAction)
    }

    func reportUpdatedFavoriteStatus(favorite existing: Favorite, status: NextToArriveUpdateStatus) {
        var updatedFavorite = existing
        updatedFavorite.nextToArriveUpdateStatus = status
        let action = UpdateFavorite(favorite: updatedFavorite, description: "Updating favorite \(updatedFavorite.favoriteId) status")
        store.dispatch(action)
    }

    func retrieveNextToArrive(favorite: Favorite, completion: (([RealTimeArrival], Favorite) -> Void)?) {
        let transitType = TransitType.fromTransitMode(favorite.transitMode)
        let startId = favorite.selectedStart.stopId
        let stopId = favorite.selectedEnd.stopId

        let originId = String(startId)
        let destinationId = String(stopId)

        let routeId = favorite.transitMode == .rail ? nil : favorite.selectedRoute.routeId

        reportUpdatedFavoriteStatus(favorite: favorite, status: .dataLoading)

        client.getRealTimeArrivals(originId: originId, destinationId: destinationId, transitType: transitType, route: routeId).then { realTimeArrivals -> Void in
            guard let arrivals = realTimeArrivals?.arrivals else { return }
            completion?(arrivals, favorite)

        }.catch { error in
            print(error.localizedDescription)
            self.reportUpdatedFavoriteStatus(favorite: favorite, status: .dataLoadingError)
        }
    }

    func mapArrivals(realTimeArrivals: [RealTimeArrival], favorite: Favorite) {

        var nextToArriveTrips = [NextToArriveTrip]()
        for realTimeArrival in realTimeArrivals {
            let startStop = mapper.mapStart(realTimeArrival: realTimeArrival)
            let endStop = mapper.mapEnd(realTimeArrival: realTimeArrival)
            let vehicleLocation = mapper.mapVehicleLocation(realTimeArrival: realTimeArrival)
            let connectionLocation = mapper.mapConnectionStation(realTimeArrival: realTimeArrival)

            if let startStop = startStop, let endStop = endStop {
                let nextToArriveTrip = NextToArriveTrip(startStop: startStop, endStop: endStop, vehicleLocation: vehicleLocation, connectionLocation: connectionLocation)
                nextToArriveTrips.append(nextToArriveTrip)
            }
        }
        reportSuccessfullyUpdatedFavorite(favorite: favorite, nextToArriveTrips: nextToArriveTrips)
    }
}

extension FavoritesNextToArriveProvider: SubscriberUnsubscriber {
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState.favoritesToUpdate
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
