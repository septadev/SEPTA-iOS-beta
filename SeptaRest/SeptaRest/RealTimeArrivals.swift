//
//  RealTimeArrivals.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class RealTimeArrivals: RestResponse {
    var origin: Int?
    var destination: Int?
    var type: String?
    public var route: String?
    var results: Int?
    public var arrivals: [RealTimeArrival]?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        if map["arrivals"].isKeyPresent {
            success = true
        }
        origin <- map["origin"]
        destination <- map["destination"]
        type <- map["type"]
        if map["route"].isKeyPresent && (map["route"].currentValue as! String) != "null" {
            route <- map["route"]
        }
        results <- map["results"]
        arrivals <- map["arrivals"]
    }
}
