//
//  NextToArriveMappers.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreLocation
import Foundation
import ReSwift
import SeptaRest
import SeptaSchedule

class NextToArriveMapper {
    func mapStart(realTimeArrival a: RealTimeArrival, transitMode: TransitMode) -> NextToArriveStop? {
        let formatter = DateFormatters.networkFormatter
        guard
            let routeId = a.orig_line_route_id,
            let routeName = a.orig_line_route_name,
            let arrivalTimeString = a.orig_arrival_time,
            let arrivalTime = formatter.date(from: arrivalTimeString),
            isValidStartDate(date: arrivalTime),
            let departureTimeString = a.orig_departure_time,
            let departureTime = formatter.date(from: departureTimeString),
            isValidStartDate(date: departureTime) else {
            return nil
        }

        return NextToArriveStop(transitMode: transitMode,
                                routeId: routeId,
                                routeName: routeName,
                                tripId: Int(a.orig_line_trip_id ?? ""),
                                arrivalTime: arrivalTime,
                                departureTime: departureTime,
                                lastStopId: Int(a.orig_last_stop_id ?? ""),
                                lastStopName: a.orig_last_stop_name,
                                delayMinutes: a.orig_delay_minutes,
                                direction: RouteDirectionCode.fromNetwork(a.orig_line_direction ?? ""),
                                vehicleLocationCoordinate: buildStartLocationCoordinate(realTimeArrival: a),
                                vehicleIds: mapVehicleIds(stopToSelect: .starts, realTimeArrival: a, transitMode: transitMode),
                                hasRealTimeData: a.orig_realtime,
                                service: a.orig_line_service
        )
    }

    func mapEnd(realTimeArrival a: RealTimeArrival, transitMode: TransitMode) -> NextToArriveStop? {
        let formatter = DateFormatters.networkFormatter
        guard
            let routeId = a.term_line_route_id,
            let routeName = a.term_line_route_name,
            let arrivalTimeString = a.term_arrival_time,
            let arrivalTime = formatter.date(from: arrivalTimeString),
            isValidEndDate(date: arrivalTime, connectionStationName: a.connection_station_name),
            let departureTimeString = a.term_departure_time,
            let departureTime = formatter.date(from: departureTimeString),
            isValidEndDate(date: departureTime, connectionStationName: a.connection_station_name) else {
            return nil
        }

        return NextToArriveStop(transitMode: transitMode,
                                routeId: routeId,
                                routeName: routeName,
                                tripId: Int(a.term_line_trip_id ?? ""),
                                arrivalTime: arrivalTime,
                                departureTime: departureTime,
                                lastStopId: Int(a.term_last_stop_id ?? ""),
                                lastStopName: a.term_last_stop_name,
                                delayMinutes: a.term_delay_minutes,
                                direction: RouteDirectionCode.fromNetwork(a.term_line_direction ?? ""),
                                vehicleLocationCoordinate: buildEndLocationCoordinate(realTimeArrival: a),
                                vehicleIds: mapVehicleIds(stopToSelect: .ends, realTimeArrival: a, transitMode: transitMode),
                                hasRealTimeData: a.term_realtime,
                                service: a.term_line_service
        )
    }

    func buildStartLocationCoordinate(realTimeArrival a: RealTimeArrival) -> CLLocationCoordinate2D? {
        if let lat = a.orig_vehicle_lat, let lon = a.orig_vehicle_lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            return nil
        }
    }

    func buildEndLocationCoordinate(realTimeArrival a: RealTimeArrival) -> CLLocationCoordinate2D? {
        if let lat = a.term_vehicle_lat, let lon = a.term_vehicle_lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            return nil
        }
    }

    func mapVehicleLocation(realTimeArrival a: RealTimeArrival, startStop: NextToArriveStop, endStop: NextToArriveStop) -> TripVehicleLocations {
        var firstLegLocation: CLLocationCoordinate2D?
        if let location = mapCoordinateFromString(a.vehicle_lat, a.vehicle_lon) {
            firstLegLocation = location
        } else if let location = mapCoordinateFromString(a.orig_vehicle_lat, a.orig_vehicle_lon) {
            firstLegLocation = location
        }
        let secondLegLocation = mapCoordinateFromString(a.term_vehicle_lat, a.term_vehicle_lon)
        let firstLegVehicleLocation = VehicleLocation(location: firstLegLocation, nextToArriveStop: startStop)
        let secondLegVehicleLocation = VehicleLocation(location: secondLegLocation, nextToArriveStop: endStop)
        return TripVehicleLocations(firstLegLocation: firstLegVehicleLocation, secondLegLocation: secondLegVehicleLocation)
    }

    func mapConnectionStation(realTimeArrival a: RealTimeArrival) -> NextToArriveConnectionStation? {
        guard let stopName = a.connection_station_name else { return nil }

        return NextToArriveConnectionStation(stopId: a.connection_station_id, stopName: stopName)
    }

    func mapVehicleIds(stopToSelect: StopToSelect, realTimeArrival a: RealTimeArrival, transitMode: TransitMode) -> [String]? {
        let useVehicleId = transitMode.useBusForDetails()
        let useConsist = transitMode.useRailForDetails()

        switch (useVehicleId, useConsist, stopToSelect, a.orig_vehicle_id) {
        case (true, false, let stopToSelect, let vehicleId) where vehicleId != .none && stopToSelect == .starts:
            return [vehicleId!]
        case (false, true, let stopToSelect, _) where stopToSelect == .starts:
            return a.consist
        case (false, true, let stopToSelect, _) where stopToSelect == .ends:
            return a.term_consist
        default:
            return nil
        }
    }

    func mapCoordinateFromString(_ latDouble: Double?, _ lonDouble: Double?) -> CLLocationCoordinate2D? {
        guard
            let latDouble = latDouble, latDouble != 0,
            let lonDouble = lonDouble, lonDouble != 0 else { return nil }

        let latDegrees = CLLocationDegrees(latDouble)
        let lonDegrees = CLLocationDegrees(lonDouble)
        let coordinate = CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees)
        if isPhillyCoordinate(coordinate) {
            return coordinate
        } else {
            return nil
        }
    }

    let philly = CLLocation(latitude: 39.952583, longitude: -75.165222)
    func isPhillyCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return philly.distance(from: location) < 160_934 // 100 miles
    }

    func isValidStartDate(date: Date) -> Bool {
        var fiveHours = DateComponents()
        fiveHours.hour = 5
        let fiveHoursFromNow: Date = Calendar.current.date(byAdding: .hour, value: 5, to: Date())!
        let fifteenMinutesAgo: Date = Calendar.current.date(byAdding: .minute, value: -15, to: Date())!
        return date > fifteenMinutesAgo && date < fiveHoursFromNow
    }

    func isValidEndDate(date: Date, connectionStationName: String?) -> Bool {
        guard let _ = connectionStationName else { return true }
        var fiveHours = DateComponents()
        fiveHours.hour = 5
        let fiveHoursFromNow: Date = Calendar.current.date(byAdding: .hour, value: 5, to: Date())!
        return date > Date() && date < fiveHoursFromNow
    }
}
