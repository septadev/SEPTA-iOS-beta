//
//  Arrivals.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class Arrivals: RestResponse {

    var origin: String?
    var destination: String?
    var results: Int?
    var arrivals: [Arrival]?

    public override func mapping(map: Map) {

        super.mapping(map: map)

        if map["arrivals"].isKeyPresent {
            success = true
        }
        origin <- map["origin"]
        destination <- map["destination"]
        results <- map["results"]
        arrivals <- map["arrivals"]
    }
}
