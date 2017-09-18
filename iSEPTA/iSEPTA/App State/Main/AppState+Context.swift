//
//  AppState+Context.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

extension AppState {
    func targetForScheduleActions() -> TargetForScheduleAction {
        if store.state.navigationState.activeNavigationController == .schedules {
            return .schedules
        } else if store.state.navigationState.activeNavigationController == .alerts {
            return .alerts
        } else {
            return .nextToArrive
        }
    }
}
