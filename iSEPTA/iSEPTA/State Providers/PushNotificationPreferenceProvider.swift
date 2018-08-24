//
//  PushNotificationPreferenceProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/22/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift

class PushNotificationPreferenceProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    static let sharedInstance = PushNotificationPreferenceProvider()

    private init() {
        store.subscribe(self) {
            $0.select {
                $0.preferenceState.pushNotificationPreferenceState.postUserNotificationPreferences
            }.skipRepeats {
                $0 == $1
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if state == true {
            PushNotificationPreferenceService.post(state: store.state.preferenceState.pushNotificationPreferenceState)
            // My job is done here, switch this back off
            store.dispatch(PostPushNotificationPreferences(boolValue: false, viewController: nil))
        }
    }
}
