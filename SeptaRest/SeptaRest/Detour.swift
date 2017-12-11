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

    public var wrappedMessage: String? {
        var result: String = ""

        if let start_location = start_location {
            result += "<p><b>Start Location:</b> \(start_location)</p>"
        }
        if let start_date_time = start_date_time {
            result += "<p><b>Start Date:</b> \(start_date_time)</p>"
        }

        if let end_date_time = end_date_time {
            result += "<p><b>End Date:</b> \(end_date_time)</p>"
        }

        if let reason = reason {
            result += "<p><b>Reason:</b> \(reason)</p>"
        }

        if let message = message {
            result += "<p><b>Details:</b> \(message)</p>"

            result += "<p>------------------------------------</p>"
        }

        return result
    }
}
