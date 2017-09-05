//
//  FilterableStop.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct FilterableStop {
    let filterString: String
    let sortString: String
    let stop: Stop

    init(stop: Stop) {

        filterString = "\(stop.stopName.lowercased())_\(stop.stopId)"
        sortString = stop.stopName.lowercased()
        self.stop = stop
    }
}
