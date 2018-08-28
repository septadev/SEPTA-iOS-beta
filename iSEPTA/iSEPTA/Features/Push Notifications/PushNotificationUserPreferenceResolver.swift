//
//  PushNotificationUserPreferenceResolver.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import UserNotifications

class PushNotificationUserPreferenceResolver: StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState.userWantsToEnablePushNotifications }
        }
    }

    func newState(state _: StoreSubscriberStateType) {
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self]
            granted, _ in
            guard let viewController = self?.viewController else { return }
            if !granted {
//                UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: viewController, withTitle: "Push Notification Authorization", message: "You need to go to Settings>Notification to enable push notifications for the SEPTA app") {
//
//                    action.boolValue = false
//                    store.dispatch(action)
//                }
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
