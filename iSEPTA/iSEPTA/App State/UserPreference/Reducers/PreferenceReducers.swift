// Septa. 2017

import Foundation
import ReSwift

struct UserPreferencesReducer {
    static func main(action: Action, state: UserPreferenceState?) -> UserPreferenceState {
        if let state = state {
            guard let action = action as? UserPreferencesAction else { return state }

            return reducePreferenceActions(action: action, state: state)

        } else {
            return UserPreferenceState()
        }
    }

    static func reducePreferenceActions(action: UserPreferencesAction, state: UserPreferenceState) -> UserPreferenceState {
        var newPref = state
        switch action {
        case let action as PreferencesRetrievedAction:
            newPref = reducePreferencesRetrievedAction(action: action, state: state)
        case let action as NewTransitModeAction:
            newPref = reduceNewTransitModeAction(action: action, state: state)
        case let action as PreferencesDatabaseLoaded:
            newPref = reducePreferencesDatabaseLoaded(action: action, state: state)
        case let action as NewStartupController:
            newPref = reduceNewStartupController(action: action, state: state)
        case let action as SetFirebaseTokenForPushNotificatoins:
            newPref = reduceSetFirebaseTokenForPushNotificatoins(action: action, state: state)
        case let action as UpdatePushNotificationPreferenceState:
            newPref = reduceUpdatePushNotificationPreferenceState(action: action, state: state)
        case let action as UserWantsToSubscribeToPushNotifications:
            newPref = reduceUserWantsToSubscribeToPushNotifications(action: action, state: state)
        case let action as UserWantsToSubscribeToSpecialAnnouncements:
            newPref = reduceUserWantsToSubscribeToSpecialAnnouncements(action: action, state: state)
        case let action as UpdateSystemAuthorizationStatusForPushNotifications:
            newPref = reduceUpdateSystemAuthorizationStatusForPushNotifications(action: action, state: state)
        case let action as UpdateDaysOfTheWeekForPushNotifications:
            newPref = reduceUpdateDaysOfTheWeekForPushNotifications(action: action, state: state)
        case let action as UpdatePushNotificationTimeframe:
            newPref = reduceUpdatePushNotificationTimeframe(action: action, state: state)
        case let action as InsertNewPushTimeframe:
            newPref = reduceInsertNewPushTimeframe(action: action, state: state)
        case let action as DeleteTimeframe:
            newPref = reduceDeleteTimeframe(action: action, state: state)
        case let action as RemovePushNotificationRoute:
            newPref = reduceRemovePushNotificationRoute(action: action, state: state)
        case let action as UpdatePushNotificationRoute:
            newPref = reduceUpdatePushNotificationRoute(action: action, state: state)
        case let action as PostPushNotificationPreferences:
            newPref = reducePostPushNotificationPreferences(action: action, state: state)
        case let action as PushNotificationPreferenceSynchronizationSuccess:
            newPref = reducePushNotificationPreferenceSynchronizationSuccess(action: action, state: state)
        case let action as PushNotificationPreferenceSynchronizationFail:
            newPref = reducePushNotificationPreferenceSynchronizationFail(action: action, state: state)
        case let action as ToggleAllPushNotificationRoutes:
            newPref = reduceToggleAllPushNotificationRoutes(action: action, state: state)
        default:
            fatalError("You passed in an action for which there is no reducer")
        }

        return newPref
    }

    static func reducePreferencesRetrievedAction(action: PreferencesRetrievedAction, state _: UserPreferenceState) -> UserPreferenceState {
        return action.userPreferenceState
    }

    static func reduceNewTransitModeAction(action: NewTransitModeAction, state: UserPreferenceState) -> UserPreferenceState {
        var newState = state
        newState.startupTransitMode = action.transitMode
        return newState
    }

    static func reducePreferencesDatabaseLoaded(action: PreferencesDatabaseLoaded, state: UserPreferenceState) -> UserPreferenceState {
        var newState = state
        newState.databaseVersion = action.databaseVersion

        return newState
    }

    static func reduceNewStartupController(action: NewStartupController, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.startupNavigationController = action.navigationController
        return userPreferenceState
    }

    // MARK: -  Called only by Unit Tests

    static func reduceUpdatePushNotificationPreferenceState(action: UpdatePushNotificationPreferenceState, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.pushNotificationPreferenceState = action.pushNotificationPreferenceState
        return userPreferenceState
    }

    // Subscription Type

    static func reduceSetFirebaseTokenForPushNotificatoins(action: SetFirebaseTokenForPushNotificatoins, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        if state.pushNotificationPreferenceState.synchronizationStatus == .upToDate {
            userPreferenceState.lastSavedPushPreferenceState = state.pushNotificationPreferenceState
            userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .pendingSave
        }
        userPreferenceState.pushNotificationPreferenceState.firebaseToken = action.token
        return userPreferenceState
    }

    static func reduceUserWantsToSubscribeToPushNotifications(action: UserWantsToSubscribeToPushNotifications, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.pushNotificationPreferenceState.userWantsToEnablePushNotifications = action.boolValue
        if action.boolValue == true {
            userPreferenceState.pushNotificationPreferenceState.userWantsToReceiveSpecialAnnoucements = true
        }
        return userPreferenceState
    }

    static func reduceUserWantsToSubscribeToSpecialAnnouncements(action: UserWantsToSubscribeToSpecialAnnouncements, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        if state.pushNotificationPreferenceState.synchronizationStatus == .upToDate {
            userPreferenceState.lastSavedPushPreferenceState = state.pushNotificationPreferenceState
            userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .pendingSave
        }
        userPreferenceState.pushNotificationPreferenceState.userWantsToReceiveSpecialAnnoucements = action.boolValue
        userPreferenceState.pushNotificationPreferenceState.postUserNotificationPreferences = true
        return userPreferenceState
    }

    static func reduceUpdateSystemAuthorizationStatusForPushNotifications(action: UpdateSystemAuthorizationStatusForPushNotifications, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.pushNotificationPreferenceState.systemAuthorizationStatusForNotifications = action.authorizationStatus
        return userPreferenceState
    }

    // MARK: - Days of the Week

    static func reduceUpdateDaysOfTheWeekForPushNotifications(action: UpdateDaysOfTheWeekForPushNotifications, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        if state.pushNotificationPreferenceState.synchronizationStatus == .upToDate {
            userPreferenceState.lastSavedPushPreferenceState = state.pushNotificationPreferenceState
            userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .pendingSave
        }
        if action.isActivated {
            userPreferenceState.pushNotificationPreferenceState.daysOfWeek.insert(action.dayOfWeek)
        } else {
            userPreferenceState.pushNotificationPreferenceState.daysOfWeek.remove(action.dayOfWeek)
        }
        return userPreferenceState
    }

    // MARK: - Time Frames

    static func reduceUpdatePushNotificationTimeframe(action: UpdatePushNotificationTimeframe, state: UserPreferenceState) -> UserPreferenceState {
        return action.block(state)
    }

    static func reduceInsertNewPushTimeframe(action _: InsertNewPushTimeframe, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        if state.pushNotificationPreferenceState.synchronizationStatus == .upToDate {
            userPreferenceState.lastSavedPushPreferenceState = state.pushNotificationPreferenceState
            userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .pendingSave
        }
        userPreferenceState.pushNotificationPreferenceState.notificationTimeWindows.append(NotificationTimeWindow.defaultAfternoonWindow())
        return userPreferenceState
    }

    static func reduceDeleteTimeframe(action: DeleteTimeframe, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        if state.pushNotificationPreferenceState.synchronizationStatus == .upToDate {
            userPreferenceState.lastSavedPushPreferenceState = state.pushNotificationPreferenceState
            userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .pendingSave
        }
        userPreferenceState.pushNotificationPreferenceState.notificationTimeWindows.remove(at: action.index)
        return userPreferenceState
    }

    // MARK: - Routes

    static func reduceRemovePushNotificationRoute(action: RemovePushNotificationRoute, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        var routeIds = userPreferenceState.pushNotificationPreferenceState.routeIds
        for route in action.routes {
            if let index = routeIds.indexOfRoute(route: route) {
                routeIds.remove(at: index)
            }
        }
        userPreferenceState.pushNotificationPreferenceState.routeIds = routeIds
        return userPreferenceState
    }

    static func reduceUpdatePushNotificationRoute(action: UpdatePushNotificationRoute, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        if state.pushNotificationPreferenceState.synchronizationStatus == .upToDate {
            userPreferenceState.lastSavedPushPreferenceState = state.pushNotificationPreferenceState
            userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .pendingSave
        }
        var routeIds = userPreferenceState.pushNotificationPreferenceState.routeIds
        if let index = routeIds.indexOfRoute(route: action.route) {
            routeIds[index] = action.route
        } else {
            routeIds.append(action.route)
        }
        userPreferenceState.pushNotificationPreferenceState.routeIds = routeIds
        return userPreferenceState
    }

    static func reducePostPushNotificationPreferences(action: PostPushNotificationPreferences, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.pushNotificationPreferenceState.postUserNotificationPreferences = action.boolValue
        return userPreferenceState
    }

    static func reducePushNotificationPreferenceSynchronizationSuccess(action _: PushNotificationPreferenceSynchronizationSuccess, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .upToDate
        return userPreferenceState
    }

    static func reducePushNotificationPreferenceSynchronizationFail(action _: PushNotificationPreferenceSynchronizationFail, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        userPreferenceState.pushNotificationPreferenceState = state.lastSavedPushPreferenceState ?? state.pushNotificationPreferenceState
        userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .upToDate
        return userPreferenceState
    }

    static func reduceToggleAllPushNotificationRoutes(action: ToggleAllPushNotificationRoutes, state: UserPreferenceState) -> UserPreferenceState {
        var userPreferenceState = state
        if state.pushNotificationPreferenceState.synchronizationStatus == .upToDate {
            userPreferenceState.lastSavedPushPreferenceState = state.pushNotificationPreferenceState
            userPreferenceState.pushNotificationPreferenceState.synchronizationStatus = .pendingSave
        }
        let routeIds: [PushNotificationRoute] = userPreferenceState.pushNotificationPreferenceState.routeIds.map {
            var route = $0
            route.isEnabled = action.boolValue
            return route
        }
        userPreferenceState.pushNotificationPreferenceState.routeIds = routeIds
        return userPreferenceState
    }
}
