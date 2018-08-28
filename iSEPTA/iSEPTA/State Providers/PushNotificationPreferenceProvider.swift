//
//  PushNotificationPreferenceProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/22/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift

class PushNotificationPreferenceProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = PostNotificationPreferencesState

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
        if state.postNow == true {
            PushNotificationPreferenceService.post(state: store.state.preferenceState.pushNotificationPreferenceState, showSuccess: state.showSuccess)
            // My job is done here, switch this back off
            store.dispatch(PostPushNotificationPreferences(postNow: false, showSuccess: false, viewController: nil))
        }
    }
}
