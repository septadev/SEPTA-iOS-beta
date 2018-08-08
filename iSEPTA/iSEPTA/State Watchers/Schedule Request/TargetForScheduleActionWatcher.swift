//
//  TargetForScheduleActionWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/8/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol TargetForScheduleActionWatcherDelegate: AnyObject {
    func targetForScheduleActionUpdated(target: TargetForScheduleAction)
}

class TargetForScheduleActionWatcher: StoreSubscriber {
    typealias StoreSubscriberStateType = NavigationController

    weak var delegate: TargetForScheduleActionWatcherDelegate?

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.navigationState.activeNavigationController }
        }
    }

    init() {
        subscribe()
    }

    func newState(state _: StoreSubscriberStateType) {
        guard let newTarget = store.state.targetForScheduleActions() else { return }
        delegate?.targetForScheduleActionUpdated(target: newTarget)
    }

    deinit {
        store.unsubscribe(self)
    }
}
