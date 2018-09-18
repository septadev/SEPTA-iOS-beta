//
//  PushNotificationMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/3/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import UserNotifications

let pushNotificationsMiddleware: Middleware<AppState> = { dispatch, getState in { next in
    return { action in

        guard let authoriziationRequiredAction = action as? SeptaAction,
            let state = getState()?.preferenceState.pushNotificationPreferenceState else { next(action); return }
        let authorizationStatus = state.systemAuthorizationStatusForNotifications
        PushNotificationMiddleware.reduce(action: authoriziationRequiredAction, state: state, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
    }
}
}

class PushNotificationMiddleware {
    static func reduce(action: SeptaAction, state: PushNotificationPreferenceState, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        if let action = action as? UserPreferencesAction {
            next(action) // we let the action go through and reverse it later if needed
            switch action {
            case let action as UpdateSystemAuthorizationStatusForPushNotifications:
                reduceUpdateSystemAuthorizationStatusForPushNotifications(action: action, state: state, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
            case let action as UpdatePushNotificationRoute:
                reduceUpdatePushNotificationRoute(action: action, state: state, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
            case let action as UserWantsToSubscribeToPushNotifications:
                reduceSubscribeToPushNotifications(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
            case let action as UserWantsToSubscribeToSpecialAnnouncements:
                reduceSubscribeToSpecialAnnouncements(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)

            default:
                break
            }
        } else if let action = action as? PushViewController, action.viewController == .customPushNotificationsController {
            reducePushViewController(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
        } else {
            next(action)
        }
    }

    static func reduceUpdateSystemAuthorizationStatusForPushNotifications(action: UpdateSystemAuthorizationStatusForPushNotifications, state _: PushNotificationPreferenceState, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        if action.authorizationStatus != authorizationStatus { // only act if the authorization status has changed
            switch action.authorizationStatus {
            case .authorized:
                dispatch(UserWantsToSubscribeToPushNotifications(viewController: nil, boolValue: true, fromAppLaunch: action.fromAppLaunch))
            case .denied, .notDetermined:
                dispatch(UserWantsToSubscribeToPushNotifications(viewController: nil, boolValue: false, fromAppLaunch: action.fromAppLaunch))
                dispatch(UserWantsToSubscribeToSpecialAnnouncements(viewController: nil, boolValue: false))
                dispatch(ToggleAllPushNotificationRoutes(boolValue: false))
            }
        }
    }

    static func reduceSubscribeToPushNotifications(action: UserWantsToSubscribeToPushNotifications, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        var reversedAction = action
        reversedAction.boolValue = !action.boolValue
        if action.boolValue { // Toggle On
            switch authorizationStatus {
            case .authorized:
                UIApplication.shared.registerForRemoteNotifications()
                if action.alsoEnableRoutes {
                    dispatch(ToggleAllPushNotificationRoutes(boolValue: true))
                }
                if !action.fromAppLaunch {
                    dispatch(PostPushNotificationPreferences(postNow: true, showSuccess: false, viewController: nil))
                }
            case .denied:
                UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                    dispatch(reversedAction)
                })
            case .notDetermined:
                requestAuthorization(onSuccess: {
                    UIApplication.shared.registerForRemoteNotifications()
                }, onFail: {
                    dispatch(reversedAction)
                }, dispatch: dispatch, next: next)
            }
        } else {
            store.dispatch(PostPushNotificationPreferences(postNow: true, showSuccess: false, viewController: nil))
        }
    }

    static func reduceSubscribeToSpecialAnnouncements(action: UserWantsToSubscribeToSpecialAnnouncements, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        var reversedAction = action
        reversedAction.boolValue = !action.boolValue
        if action.boolValue { // Toggle On
            switch authorizationStatus {
            case .authorized:
                break
            case .denied:
                UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                    dispatch(reversedAction)
                })
            case .notDetermined:
                requestAuthorization(onSuccess: {
                    return
                }, onFail: {
                    dispatch(reversedAction)
                }, dispatch: dispatch, next: next)
            }
        }
    }

    static func reduceUpdatePushNotificationRoute(action: UpdatePushNotificationRoute, state: PushNotificationPreferenceState, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        switch authorizationStatus {
        case .authorized:
            if action.route.isEnabled && !state.userWantsToEnablePushNotifications {
                UIAlert.presentEnableAllRoutes(viewController: action.viewController, pushNotificationRoute: action.route)
            }
            if action.postImmediately {
                dispatch(PostPushNotificationPreferences(postNow: true, showSuccess: false, viewController: nil))
            }
        case .denied:
            UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                dispatch(RemovePushNotificationRoute(routes: [action.route], viewController: action.viewController))
            })
        case .notDetermined:
            requestAuthorization(
                onSuccess: {
                    if action.postImmediately {
                        dispatch(PostPushNotificationPreferences(postNow: true, showSuccess: false, viewController: nil))
                    }
                    return
                }, onFail: {
                    dispatch(RemovePushNotificationRoute(routes: [action.route], viewController: nil))
            }, dispatch: dispatch, next: next)
        }
    }

    static func reducePushViewController(action: PushViewController, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        switch authorizationStatus {
        case .authorized:
            next(action)
        case .denied:

            UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: nil, completion: nil)

        case .notDetermined:
            requestAuthorization(
                onSuccess: {
                    next(action)
                }, onFail: {
            }, dispatch: dispatch, next: next)
        }
    }

    static func requestAuthorization(onSuccess: (() -> Void)?, onFail: (() -> Void)?, dispatch: @escaping DispatchFunction, next _: @escaping DispatchFunction) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if error == nil {
                DispatchQueue.main.async {
                    if granted {
                        dispatch(UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: .authorized, fromAppLaunch: false))
                        onSuccess?()
                    } else {
                        dispatch(UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: .denied, fromAppLaunch: false))
                        onFail?()
                    }
                }
            }
        }
    }
}
