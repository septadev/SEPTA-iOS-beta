//
//  RealTimeArrivalDetail.swift
//  SeptaRest
//
//  Created by Mark Broski on 10/10/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import Foundation

public protocol RealTimeArrivalDetail {
    var tripid: Int? { get }
    var latitude: Double? { get }
    var longitude: Double? { get }
    var line: String? { get }
}
