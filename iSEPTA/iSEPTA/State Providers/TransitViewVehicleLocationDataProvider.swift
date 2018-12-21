//
//  TransitViewVehicleLocationDataProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/11/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import MapKit
import ReSwift
import SeptaRest
import SeptaSchedule

class TransitViewVehicleLocationDataProvider: StoreSubscriber {
    static let sharedInstance = TransitViewVehicleLocationDataProvider()

    typealias StoreSubscriberStateType = Bool

    init() {
        subscribe()
    }

    private func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.transitViewState.refreshVehicleLocationData
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if state {
            refreshVehicleLocationData()
        }
    }

    private func refreshVehicleLocationData() {
        var routeIds: [String] = []
        let model = store.state.transitViewState.transitViewModel
        if let first = model.firstRoute {
            routeIds.append(first.routeId)
        }
        if let second = model.secondRoute {
            routeIds.append(second.routeId)
        }
        if let third = model.thirdRoute {
            routeIds.append(third.routeId)
        }
        if routeIds.count > 0 {
            downloadVehicleLocationData(routeIds: routeIds, model: model)
        }
    }

    private func downloadVehicleLocationData(routeIds: [String], model: TransitViewModel) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        let service = TransitViewService()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let downloadTask = service.transitViewDataTask(for: routeIds) { data, _, error in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }

                guard error == nil else { return }
                guard let data = data else { return }

                do {
                    let decoder = JSONDecoder()
                    let routeData = try decoder.decode(TransitViewRouteData.self, from: data)
                    let vehicleLocations = self.convertToVehicleLocations(routeData, model: model)
                    DispatchQueue.main.async {
                        let action = TransitViewRouteLocationsDownloaded(locations: vehicleLocations, description: "TransitView vehicle locations downloaded")
                        store.dispatch(action)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
            downloadTask.resume()
        }
    }

    private func convertToVehicleLocations(_ routeData: TransitViewRouteData, model: TransitViewModel) -> [TransitViewVehicleLocation] {
        var vehicleLocations: [TransitViewVehicleLocation] = []
        for route in routeData.routes {
            for (routeId, locations) in route {
                for vehicle in locations {
                    guard let lat = Double(vehicle.lat), let lng = Double(vehicle.lng) else { break }
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

                    var mode: TransitMode = .bus
                    if let firstRoute = model.firstRoute, firstRoute.routeId == routeId {
                        mode = firstRoute.mode()
                    } else if let secondRoute = model.secondRoute, secondRoute.routeId == routeId {
                        mode = secondRoute.mode()
                    } else if let thirdRoute = model.thirdRoute, thirdRoute.routeId == routeId {
                        mode = thirdRoute.mode()
                    }

                    let location = TransitViewVehicleLocation(coordinate: coordinate, mode: mode, routeId: routeId, vehicleId: vehicle.VehicleID, heading: vehicle.heading, block: vehicle.BlockID, late: vehicle.late, destination: vehicle.destination)
                    vehicleLocations.append(location)
                }
            }
        }
        return vehicleLocations
    }

    deinit {
        store.unsubscribe(self)
    }
}

struct TransitViewRouteData: Codable {
    let routes: [[String: [TransitRouteVehicle]]]
}

struct TransitRouteVehicle: Codable {
    let lat: String
    let lng: String
    let label: String
    let VehicleID: String
    let BlockID: String
    let Direction: String
    let destination: String
    let Offset: String
    let heading: Int
    let late: Int
    let Offset_sec: String
    let trip: String
}
