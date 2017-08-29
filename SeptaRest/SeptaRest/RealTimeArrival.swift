//
//  RealTimeArrival.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class RealTimeArrival: Mappable {

    var orig_line_route_id: String?
    var orig_line_route_name: String?
    var term_line_route_id: String?
    var term_line_route_name: String?
    var connection_station_id: String?
    var connection_station_name: String?
    var orig_line_trip_id: String?
    var term_line_trip_id: String?
    var orig_arrival_time: String?
    var orig_departure_time: String?
    var term_arrival_time: String?
    var term_departure_time: String?
    var orig_delay_minutes: Int?
    var term_delay_minutes: Int?
    var orig_last_stop_id: String?
    var orig_last_stop_name: String?
    var term_last_stop_id: String?
    var term_last_stop_name: String?
    var orig_line_direction: String?
    var term_line_direction: String?
    var vehicle_lat: String?
    var vehicle_lon: String?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {

        orig_line_route_id <- map["orig_line_route_id"]
        orig_line_route_name <- map["orig_line_route_name"]
        term_line_route_id <- map["term_line_route_id"]
        term_line_route_name <- map["term_line_route_name"]
        connection_station_id <- map["connection_station_id"]
        connection_station_name <- map["connection_station_name"]
        orig_line_trip_id <- map["orig_line_trip_id"]
        term_line_trip_id <- map["term_line_trip_id"]
        orig_arrival_time <- map["orig_arrival_time"]
        orig_departure_time <- map["orig_departure_time"]
        term_arrival_time <- map["term_arrival_time"]
        term_departure_time <- map["term_departure_time"]
        orig_delay_minutes <- map["orig_delay_minutes"]
        term_delay_minutes <- map["term_delay_minutes"]
        orig_last_stop_id <- map["orig_last_stop_id"]
        orig_last_stop_name <- map["orig_last_stop_name"]
        term_last_stop_id <- map["term_last_stop_id"]
        term_last_stop_name <- map["term_last_stop_name"]
        orig_line_direction <- map["orig_line_direction"]
        term_line_direction <- map["term_line_direction"]
        vehicle_lat <- map["vehicle_lat"]
        vehicle_lon <- map["vehicle_lon"]
    }
}
