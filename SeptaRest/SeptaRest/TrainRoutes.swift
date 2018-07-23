//
//  TrainRoutes.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class TrainRoutes: RestResponse {
    var results: Int?
    var route: Int?
    var trains: [TrainRoute]?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        if map["trains"].isKeyPresent {
            success = true
        }
        results <- map["results"]
        route <- map["route"]
        trains <- map["trains"]
    }
}
