//
//  Alert.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class Alert: Mappable {

 public  var route_id: String?
 public  var route_name: String?
 public  var mode: String?
 public  var advisory: Bool?
 public  var detour: Bool?
 public  var alert: Bool?
 public  var suspended: Bool?
 public  var last_updated: String?
 public  var snow: Bool?
 public  var description: String?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {

        route_id <- map["route_id"]
        route_name <- map["route_name"]
        mode <- map["mode"]
        advisory <- map["advisory"]
        detour <- map["detour"]
        alert <- map["alert"]
        suspended <- map["suspended"]
        last_updated <- map["last_updated"]
        snow <- map["snow"]
        description <- map["description"]
    }
}
