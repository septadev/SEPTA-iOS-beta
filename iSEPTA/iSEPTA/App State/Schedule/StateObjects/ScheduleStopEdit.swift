//
//  ScheduleStopEdit.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct ScheduleStopEdit {
    let stopToEdit: StopToSelect

    init(stopToEdit: StopToSelect = .starts) {
        self.stopToEdit = stopToEdit
    }
}

extension ScheduleStopEdit: Equatable {}
func ==(lhs: ScheduleStopEdit, rhs: ScheduleStopEdit) -> Bool {
    var areEqual = true

    areEqual = lhs.stopToEdit == rhs.stopToEdit
    guard areEqual else { return false }

    return areEqual
}
