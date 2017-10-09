//
//  Detour.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class Detour: Mappable {

    public var message: String?
    var start_location: String?
    var start_date_time: String?
    var end_date_time: String?
    var reason: String?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {

        message <- map["message"]
        start_location <- map["start_location"]
        start_date_time <- map["start_date_time"]
        end_date_time <- map["end_date_time"]
        reason <- map["reason"]
    }
}
