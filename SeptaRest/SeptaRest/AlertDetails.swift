//
//  AlertDetails.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class AlertDetails: RestResponse {

    var route: String?
    var routeName: String?
  public  var alerts: [AlertDetails_Alert]?
    var results: Int?

    public override func mapping(map: Map) {

        super.mapping(map: map)

        if map["alerts"].isKeyPresent {
            success = true
        }

        route <- map["route"]
        routeName <- map["route_name"]
        alerts <- map["alerts"]
        results <- map["results"]
    }
}
