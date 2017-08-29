//
//  TransitRoute.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class TransitRoute: Mappable {

    var trip: String?
    var latitude: Float?
    var longitude: Float?
    var label: String?
    var vehicle_id: String?
    var block_id: String?
    var direction: String?
    var destination: String?
    var late: Int?
    var offset: Int?
    var offset_sec: Int?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {

        trip <- map["trip"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        label <- map["label"]
        vehicle_id <- map["vehicle_id"]
        block_id <- map["block_id"]
        direction <- map["direction"]
        destination <- map["destination"]
        late <- map["late"]
        offset <- map["offset"]
        offset_sec <- map["offset_sec"]
    }
}
