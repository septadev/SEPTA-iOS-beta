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
    let septaConnection: SEPTAConnection?
    init(septaConnection: SEPTAConnection? = nil) {
        self.septaConnection = septaConnection
    }
}

extension MoreState: Equatable {}
func == (lhs: MoreState, rhs: MoreState) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.septaConnection, newValue: rhs.septaConnection).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
