//
//  AppState+Context.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

extension AppState {
    func targetForScheduleActions() -> TargetForScheduleAction? {

        switch store.state.navigationState.activeNavigationController {
        case .schedules: return .schedules
        case .alerts: return .alerts
        case .nextToArrive: return .nextToArrive
        case .favorites: return .favorites
        default: return nil
        }
    }

    func targetForScheduleActionsScheduleRequest() -> ScheduleRequest {
        guard let targetForScheduleAction = store.state.targetForScheduleActions() else { return ScheduleRequest() }
        switch targetForScheduleAction {
        case .nextToArrive: return store.state.nextToArriveState.scheduleState.scheduleRequest
        case .favorites : return store.state.favoritesState.nextToArriveScheduleRequest
        case .alerts: return store.state.alertState.scheduleState.scheduleRequest
        case .schedules: return store.state.scheduleState.scheduleRequest
        default: return ScheduleRequest()
        }
    }

    func watcherForScheduleActions() -> BaseScheduleRequestWatcher? {
        switch store.state.navigationState.activeNavigationController {
        case .schedules: return ScheduleState_ScheduleRequestWatcher()
        case .alerts: return AlertState_ScheduleState_ScheduleRequestWatcher()
        case .nextToArrive: return NextToArriveState_ScheduleState_ScheduleRequestWatcher()
        case .favorites: return FavoriteState_ScheduleRequestWatcher()
        default: return nil
        }
    }
}
