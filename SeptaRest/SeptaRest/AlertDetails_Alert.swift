//
//  AlertDetails_Alert.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class AlertDetails_Alert: Mappable {
    public var route_id: String?
    public var route_name: String?
    public var message: String?
    public var advisory_message: String?
    public var detour: Detour?
    public var last_updated: String?
    public var snow: Bool?

    public required init?(map _: Map) {
    }

    public init() {}

    public func mapping(map: Map) {
        route_id <- map["route_id"]
        route_name <- map["route_name"]
        message <- map["message"]
        advisory_message <- map["advisory_message"]
        detour <- map["detour"]
        last_updated <- map["last_updated"]
        snow <- map["snow"]
    }
}
