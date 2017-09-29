//
//  MoreState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct MoreState {
    let septaUrlInfo: SeptaUrlInfo?
    init(septaUrlInfo: SeptaUrlInfo? = nil) {
        self.septaUrlInfo = septaUrlInfo
    }
}

extension MoreState: Equatable {}
func ==(lhs: MoreState, rhs: MoreState) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.septaUrlInfo, newValue: rhs.septaUrlInfo).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
