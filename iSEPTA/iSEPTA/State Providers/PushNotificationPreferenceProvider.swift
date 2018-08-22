//
//  PushNotificationPreferenceProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/22/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift

class PushNotificationPreferenceProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = PushNotificationPreferenceState

    static let sharedInstance = PushNotificationPreferenceProvider()

    private init() {
        store.subscribe(self) {
            $0.select {
                $0.preferenceState.pushNotificationPreferenceState
            }.skipRepeats {
                $0 == $1
            }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if state.postUserNotificationPreferences == true {
            PushNotificationPreferenceService.post(state: state)
            // My job is done here, switch this back off
            store.dispatch(PostPushNotificationPreferences(boolValue: false, viewController: nil))
        }
    }
}
