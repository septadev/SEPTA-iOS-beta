//
//  TrainRoute.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class TrainRoute: Mappable {
    var latitude: Float?
    var longitude: Float?
    var number: String?
    var service: String?
    var destination: String?
    var nextStop: String?
    var late: Int?
    var source: String?
    var track: String?
    var trackChange: String?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        number <- map["number"]
        service <- map["service"]
        destination <- map["destination"]
        nextStop <- map["nextStop"]
        late <- map["late"]
        source <- map["source"]
        track <- map["track"]
        trackChange <- map["trackChange"]
    }
}
