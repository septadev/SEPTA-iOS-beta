//
//  UserPermissions.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UserNotifications

/// Insures that user notifications settings get blown up when system notification status changes.
class PushNotificationSystemStatusResolver: StoreSubscriber {
    typealias StoreSubscriberStateType = PushNotificationAuthorizationState

    init() {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState.systemAuthorizationStatusForNotifications }
        }
    }

    func newState(state _: StoreSubscriberStateType) {
//        switch state {
//        case .notDetermined, .denied: disableNotificationDetails()
//        default: break
//        }
    }

//    func disableNotificationDetails() {
//        store.dispatch(UserWantsToSubscribeToPushNotifications())
//        store.dispatch(UserWantsToSubscribeToSpecialAnnouncements())
//        store.dispatch(UserWantsToSubscribeToOverideDoNotDisturb())
//    }

    deinit {
        store.unsubscribe(self)
    }
}
