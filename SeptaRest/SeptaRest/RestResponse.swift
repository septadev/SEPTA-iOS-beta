//
//  ApiResponse.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import ObjectMapper

public class RestResponse: Mappable {

    var success: Bool = false
    var error: Error?

    public required init?(map _: Map) {
    }

    public func mapping(map: Map) {

        error <- map["message"]
    }
}
