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
        switch action {
        case let action as UpdateSystemAuthorizationStatusForPushNotifications:
            next(action)
            reduceUpdateSystemAuthorizationStatusForPushNotifications(action: action, state: state, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
        case let action as AddPushNotificationRoute:
            next(action)
            reduceAddPushNotificationRoute(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
        case let action as ToggleSwitchAction:
            next(action)
            reduceAddPushNotificationFeature(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
        case let action as PushViewController where action.viewController == .customPushNotificationsController:
            reducePushCustomizePushNotifications(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
        default:
            next(action)
        }
    }

    static func reduceUpdateSystemAuthorizationStatusForPushNotifications(action: UpdateSystemAuthorizationStatusForPushNotifications, state _: PushNotificationPreferenceState, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        if action.authorizationStatus != authorizationStatus {
            switch action.authorizationStatus {
            case .authorized:
                dispatch(UserWantsToSubscribeToPushNotifications(viewController: nil, boolValue: true))

            case .denied:
                dispatch(UserWantsToSubscribeToPushNotifications(viewController: nil, boolValue: false))
                dispatch(UserWantsToSubscribeToSpecialAnnouncements(viewController: nil, boolValue: false))
                dispatch(UserWantsToSubscribeToOverideDoNotDisturb(viewController: nil, boolValue: false))
                dispatch(RemoveAllPushNotificationRoutes())
            case .notDetermined:
                break
            }
        }
    }

    static func reduceAddPushNotificationRoute(action: AddPushNotificationRoute, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        switch authorizationStatus {
        case .authorized:
            break // No need to do anything, the action has already been allowed through

        case .denied:
            UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                dispatch(RemovePushNotificationRoute(routes: [action.route], viewController: action.viewController))
            })

        case .notDetermined:
            let actionOnFail = RemovePushNotificationRoute(routes: [action.route], viewController: action.viewController)
            requestAuthorization(actionOnSuccess: action, actionOnFail: actionOnFail, dispatch: dispatch, next: next)
        }
    }

    static func reduceAddPushNotificationFeature(action: ToggleSwitchAction, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        var reversedAction = action
        reversedAction.boolValue = !action.boolValue

        if action.boolValue {
            switch authorizationStatus {
            case .authorized:
                break // No need to do anything, the action has already been allowed through

            case .denied:
                UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                    dispatch(reversedAction)
                })

            case .notDetermined:

                requestAuthorization(actionOnSuccess: nil, actionOnFail: reversedAction, dispatch: dispatch, next: next)
            }

        } else {
            if let _ = action as? UserWantsToSubscribeToPushNotifications {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        }
    }

    static func reducePushCustomizePushNotifications(action: PushViewController, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        switch authorizationStatus {
        case .authorized:
            next(action)
        case .denied:

            UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: nil, completion: nil)

        case .notDetermined:

            requestAuthorization(actionOnSuccess: action, actionOnFail: nil, dispatch: dispatch, next: next)
        }
    }

    static func requestAuthorization(actionOnSuccess: SeptaAction?, actionOnFail: SeptaAction?, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if error == nil {
                DispatchQueue.main.async {
                    if granted {
                        next(UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: .authorized))
                        if let actionOnSuccess = actionOnSuccess {
                            dispatch(actionOnSuccess)
                        }
                        UIApplication.shared.registerForRemoteNotifications()
                    } else {
                        dispatch(UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: .denied))
                        if let actionOnFail = actionOnFail {
                            dispatch(actionOnFail)
                        }
                    }
                }
            }
        }
    }
}
