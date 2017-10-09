//
//  Alerts.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class Alerts: RestResponse {

    public var alerts: [Alert]?
    public var results: Int?

    public override func mapping(map: Map) {

        super.mapping(map: map)

        if map["alerts"].isKeyPresent {
            success = true
        }
        alerts <- map["alerts"]
        results <- map["results"]
    }
}
