//
//  ScheduleStopEdit.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct ScheduleStopEdit {
    let stopToEdit: StopToSelect
    let searchMode: StopEditSearchMode
    let selectedAddress: DisplayAddress?

    init(stopToEdit: StopToSelect = .starts, searchMode: StopEditSearchMode = .directLookup, selectedAddress: DisplayAddress? = nil) {
        self.stopToEdit = stopToEdit
        self.searchMode = searchMode
        self.selectedAddress = selectedAddress
    }
}

extension ScheduleStopEdit: Equatable {}
func == (lhs: ScheduleStopEdit, rhs: ScheduleStopEdit) -> Bool {
    var areEqual = true

    areEqual = lhs.stopToEdit == rhs.stopToEdit
    guard areEqual else { return false }

    areEqual = lhs.searchMode == rhs.searchMode
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.selectedAddress, newValue: rhs.selectedAddress).equalityResult()
    guard areEqual else { return false }

    return areEqual
}
