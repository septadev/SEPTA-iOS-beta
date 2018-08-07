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
            case let action as AddPushNotificationRoute:
                reduceAddPushNotificationRoute(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
            case let action as RemovePushNotificationRoute:
                unregisterRoutes(routeIds: action.routes, state: state)
            case _ as ToggleAllPushNotificationRoutes:
                unregisterRoutes(routeIds: nil, state: state)
            case let action as UpdatePushNotificationRoute:
                reduceUpdatePushNotificationRoute(action: action, state: state, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
            case let action as UserWantsToSubscribeToPushNotifications:
                reduceSubscribeToPushNotifications(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
            case let action as UserWantsToSubscribeToSpecialAnnouncements:
                reduceSubscribeToSpecialAnnouncements(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)
            case let action as UserWantsToSubscribeToOverideDoNotDisturb:
                reduceOverrideDoNotDisturb(action: action, authorizationStatus: authorizationStatus, dispatch: dispatch, next: next)

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
                dispatch(UserWantsToSubscribeToPushNotifications(viewController: nil, boolValue: true))
            case .denied, .notDetermined:
                dispatch(UserWantsToSubscribeToPushNotifications(viewController: nil, boolValue: false))
                dispatch(UserWantsToSubscribeToSpecialAnnouncements(viewController: nil, boolValue: false))
                dispatch(UserWantsToSubscribeToOverideDoNotDisturb(viewController: nil, boolValue: false))
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
                dispatch(UserWantsToSubscribeToSpecialAnnouncements(viewController: action.viewController, boolValue: true, sender: "reduceSubscribeToPushNotifications"))
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
        } else { // Toggle Off
            dispatch(UserWantsToSubscribeToSpecialAnnouncements(viewController: nil, boolValue: false))
            dispatch(UserWantsToSubscribeToOverideDoNotDisturb(viewController: nil, boolValue: false))
            dispatch(ToggleAllPushNotificationRoutes(boolValue: false))
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }

    static func reduceSubscribeToSpecialAnnouncements(action: UserWantsToSubscribeToSpecialAnnouncements, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        var reversedAction = action
        reversedAction.boolValue = !action.boolValue
        if action.boolValue { // Toggle On
            switch authorizationStatus {
            case .authorized:
                subscribeToSpecialAnnouncements(boolValue: true)
            case .denied:
                UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                    dispatch(reversedAction)
                })
            case .notDetermined:
                requestAuthorization(onSuccess: {
                    subscribeToSpecialAnnouncements(boolValue: true)
                }, onFail: {
                    dispatch(reversedAction)
                }, dispatch: dispatch, next: next)
            }
        } else { // Toggle Off
            subscribeToSpecialAnnouncements(boolValue: false)
        }
    }

    static func reduceOverrideDoNotDisturb(action: UserWantsToSubscribeToOverideDoNotDisturb, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        var reversedAction = action
        reversedAction.boolValue = !action.boolValue
        if action.boolValue { // Toggle On
            switch authorizationStatus {
            case .authorized:
                subscribeToDoNotDisturb(boolValue: action.boolValue)
            case .denied:
                UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                    dispatch(reversedAction)
                })
            case .notDetermined:
                requestAuthorization(
                    onSuccess: {
                        subscribeToDoNotDisturb(boolValue: action.boolValue)
                    }, onFail: {
                        dispatch(reversedAction)
                }, dispatch: dispatch, next: next)
            }
        } else { // Toggle Off
            // Nothing to do here
        }
    }

    static func reduceAddPushNotificationRoute(action: AddPushNotificationRoute, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        switch authorizationStatus {
        case .authorized:
            subscribeWithoutThrows(routeId: action.route.routeId)
            dispatch(UserWantsToSubscribeToPushNotifications(viewController: nil, boolValue: true))
        case .denied:
            UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                dispatch(RemovePushNotificationRoute(routes: [action.route], viewController: action.viewController))
            })
        case .notDetermined:
            requestAuthorization(
                onSuccess: {
                    subscribeWithoutThrows(routeId: action.route.routeId)
                }, onFail: {
                    dispatch(RemovePushNotificationRoute(routes: [action.route], viewController: nil))
            }, dispatch: dispatch, next: next)
        }
    }

    static func reduceUpdatePushNotificationRoute(action: UpdatePushNotificationRoute, state: PushNotificationPreferenceState, authorizationStatus: PushNotificationAuthorizationState, dispatch: @escaping DispatchFunction, next: @escaping DispatchFunction) {
        switch authorizationStatus {
        case .authorized:
            updateRouteSubscription(route: action.route)
            if action.route.isEnabled && !state.userWantsToEnablePushNotifications {
                UIAlert.presentEnableAllRoutes(viewController: action.viewController, pushNotificationRoute: action.route)
            }
        case .denied:
            UIAlert.presentNavigationToSettingsNeededAlertFrom(viewController: action.viewController, completion: {
                dispatch(RemovePushNotificationRoute(routes: [action.route], viewController: action.viewController))
            })
        case .notDetermined:
            requestAuthorization(
                onSuccess: {
                    updateRouteSubscription(route: action.route)
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
                        dispatch(UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: .authorized))
                        onSuccess?()
                    } else {
                        dispatch(UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: .denied))
                        onFail?()
                    }
                }
            }
        }
    }

    static func unregisterRoutes(routeIds: [PushNotificationRoute]?, state: PushNotificationPreferenceState) {
        let routes = routeIds ?? state.routeIds
        for route in routes {
            unSubscribeWithoutThrows(routeId: route.routeId)
        }
    }

    static func updateRouteSubscription(route: PushNotificationRoute) {
        do {
            if route.isEnabled {
                try NotificationsManager.subscribe(routeId: route.routeId)
            } else {
                try NotificationsManager.unsubscribe(routeId: route.routeId)
            }

        } catch {
            print(error.localizedDescription)
        }
    }

    static func subscribeWithoutThrows(routeId: String) {
        do {
            try NotificationsManager.subscribe(routeId: routeId)

        } catch {
            print(error.localizedDescription)
        }
    }

    static func unSubscribeWithoutThrows(routeId: String) {
        do {
            try NotificationsManager.unsubscribe(routeId: routeId)

        } catch {
            print(error.localizedDescription)
        }
    }

    static func subscribeToSpecialAnnouncements(boolValue isOn: Bool) {
        do {
            if isOn {
                try NotificationsManager.subscribeToSpecialAnnouncements()
            } else {
                try NotificationsManager.unSubscribeToSpecialAnnouncements()
            }

        } catch {
            print(error.localizedDescription)
        }
    }

    static func subscribeToDoNotDisturb(boolValue _: Bool) {
    }
}
