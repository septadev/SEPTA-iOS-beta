//
//  Arrival.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class Arrival: Mappable {
    var number: String?
    var line: String?
    var departure_time: String?
    var arrival_time: String?
    var delay: String?
    var direct: Bool?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {
        number <- map["number"]
        line <- map["line"]
        departure_time <- map["departure_time"]
        arrival_time <- map["arrival_time"]
        delay <- map["delay"]
        direct <- map["direct"]
    }
}
