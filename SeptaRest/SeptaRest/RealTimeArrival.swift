//
//  RealTimeArrival.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

/*"arrival_time": "18:20:00",
"connection_station_id": null,
"connection_station_name": null,
"orig_arrival_time": "2017-09-06T21:51:00.000Z",
"orig_delay_minutes": null,
"orig_departure_time": "2017-09-06T21:51:00.000Z",
"orig_last_stop_id": 809,
"orig_last_stop_name": "Willow Grove Park Mall",
"orig_line_direction": null,
"orig_line_route_id": "22",
"orig_line_route_name": "\"Olney Transportation Center\"",
"orig_line_trip_id": "947545",
"term_arrival_time": "2017-09-06T22:20:00.000Z",
"term_delay_minutes": null,
"term_departure_time": "2017-09-06T22:20:00.000Z",
"term_last_stop_id": 809,
"term_last_stop_name": "Willow Grove Park Mall",
"term_line_direction": null,
"term_line_route_id": "22",
"term_line_route_name": "\"Olney Transportation Center\"",
"term_line_trip_id": "947545",
"vehicle_lat": null,
"vehicle_lon": null
*/

public class RealTimeArrival: Mappable {

 public  var connection_station_id: String?
  public var connection_station_name: String?
  public var orig_arrival_time: String?
  public var orig_delay_minutes: Int?
  public var orig_departure_time: String?
  public var orig_last_stop_id: String?
  public var orig_last_stop_name: String?
  public var orig_line_direction: String?
  public var orig_line_route_id: String?
  public var orig_line_route_name: String?
  public var orig_line_trip_id: String?
  public var term_arrival_time: String?
  public var term_delay_minutes: Int?
  public var term_departure_time: String?
  public var term_last_stop_id: String?
  public var term_last_stop_name: String?
  public var term_line_direction: String?
  public var term_line_route_id: String?
  public var term_line_route_name: String?
  public var term_line_trip_id: String?
  public var vehicle_lat: String?
  public var vehicle_lon: String?
  public var orig_vehicle_lat: String?
  public var orig_vehicle_lon: String?
  public var term_vehicle_lat: String?
  public var term_vehicle_lon: String?

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
         orig_vehicle_lat <- map["orig_vehicle_lat"]
        orig_vehicle_lon <- map["orig_vehicle_lon"]
         term_vehicle_lat <- map["term_vehicle_lat"]
        term_vehicle_lon <- map["term_vehicle_lon"]
    }
}
