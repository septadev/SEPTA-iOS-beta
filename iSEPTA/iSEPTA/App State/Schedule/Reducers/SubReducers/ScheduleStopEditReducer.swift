//
//  ScheduleStopEditReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct ScheduleStopEditReducer {

    static func initStopEdit() -> ScheduleStopEdit {
        return ScheduleStopEdit()
    }

    static func reduceStopEdit(action: ScheduleAction, scheduleStopEdit: ScheduleStopEdit) -> ScheduleStopEdit {
        var newScheduleStopEdit: ScheduleStopEdit
        switch action {

        case let action as CurrentStopToEdit:
            newScheduleStopEdit = reduceCurrentStopToEdit(action: action, scheduleStopEdit: scheduleStopEdit)
        case let action as StopSearchModeChanged:
            newScheduleStopEdit = reduceSearchModeChanged(action: action, scheduleStopEdit: scheduleStopEdit)
        case let action as AddressSelected:
            newScheduleStopEdit = reduceAddressSelected(action: action, scheduleStopEdit: scheduleStopEdit)
        default:
            newScheduleStopEdit = scheduleStopEdit
        }
        return newScheduleStopEdit
    }

    static func reduceCurrentStopToEdit(action: CurrentStopToEdit, scheduleStopEdit _: ScheduleStopEdit) -> ScheduleStopEdit {
        return ScheduleStopEdit(stopToEdit: action.stopToEdit)
    }

    static func reduceSearchModeChanged(action: StopSearchModeChanged, scheduleStopEdit: ScheduleStopEdit) -> ScheduleStopEdit {
        return ScheduleStopEdit(stopToEdit: scheduleStopEdit.stopToEdit, searchMode: action.searchMode)
    }

    static func reduceAddressSelected(action: AddressSelected, scheduleStopEdit: ScheduleStopEdit) -> ScheduleStopEdit {
        return ScheduleStopEdit(stopToEdit: scheduleStopEdit.stopToEdit, searchMode: .directLookupWithAddress, selectedAddress: action.selectedAddress)
    }
}
