//
//  ApiError.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class Error: Mappable {
    var errorName: String?
    var errorCode: String?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {
        errorName <- map["message"]
        errorCode <- map["errorCode"]
    }
}
