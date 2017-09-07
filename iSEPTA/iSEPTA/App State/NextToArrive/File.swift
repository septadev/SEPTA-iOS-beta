//
//  File.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct NextToArriveService {
    let service: String
    let consist: [Int]
    init(service: String, consist: [Int] = [Int]()) {
        self.service = service
        self.consist = consist
    }
}

extension NextToArriveService: Equatable {}
func ==(lhs: NextToArriveService, rhs: NextToArriveService) -> Bool {
    var areEqual = true

    areEqual = lhs.service == rhs.service
    guard areEqual else { return false }

    areEqual = lhs.consist == rhs.consist
    guard areEqual else { return false }

    return areEqual
}
