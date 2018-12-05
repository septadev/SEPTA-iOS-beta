// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

struct AppState: StateType {
    var navigationState: NavigationState
    var scheduleState: ScheduleState
    var preferenceState: UserPreferenceState
    var alertState: AlertState
    var addressLookupState: AddressLookupState
    var locationState: LocationState
    var favoritesState: FavoritesState
    var nextToArriveState: NextToArriveState
    var tripDetailState: TripDetailState
    var pushNotificationTripDetailState: PushNotificationTripDetailState
    var databaseState: DatabaseState
    var moreState: MoreState
    var transitViewState: TransitViewState
    var databaseUpdateState: DatabaseUpdateState
    var notificationState: NotificationState

    init(
        navigationState: NavigationState, scheduleState: ScheduleState, preferenceState: UserPreferenceState, alertState: AlertState,
        addressLookupState: AddressLookupState, locationState: LocationState, favoriteState: FavoritesState, nextToArriveState: NextToArriveState,
        tripDetailState: TripDetailState, pushNotificationTripDetailState: PushNotificationTripDetailState, databaseState: DatabaseState,
        moreState: MoreState, transitViewState: TransitViewState, databaseUpdateState: DatabaseUpdateState, notificationState: NotificationState
    ) {
        self.navigationState = navigationState
        self.scheduleState = scheduleState
        self.preferenceState = preferenceState
        self.alertState = alertState
        self.addressLookupState = addressLookupState
        self.locationState = locationState
        favoritesState = favoriteState
        self.nextToArriveState = nextToArriveState
        self.tripDetailState = tripDetailState
        self.pushNotificationTripDetailState = pushNotificationTripDetailState
        self.databaseState = databaseState
        self.moreState = moreState
        self.transitViewState = transitViewState
        self.databaseUpdateState = databaseUpdateState
        self.notificationState = notificationState
    }
}

extension AppState: Equatable {}
func == (lhs: AppState, rhs: AppState) -> Bool {
    var areEqual = true

    areEqual = lhs.navigationState == rhs.navigationState
    guard areEqual else { return false }

    areEqual = lhs.scheduleState == rhs.scheduleState
    guard areEqual else { return false }

    areEqual = lhs.preferenceState == rhs.preferenceState
    guard areEqual else { return false }

    areEqual = lhs.alertState == rhs.alertState
    guard areEqual else { return false }

    areEqual = lhs.addressLookupState == rhs.addressLookupState
    guard areEqual else { return false }

    areEqual = lhs.locationState == rhs.locationState
    guard areEqual else { return false }

    areEqual = lhs.favoritesState == rhs.favoritesState
    guard areEqual else { return false }

    areEqual = lhs.nextToArriveState == rhs.nextToArriveState
    guard areEqual else { return false }

    areEqual = lhs.tripDetailState == rhs.tripDetailState
    guard areEqual else { return false }

    areEqual = lhs.pushNotificationTripDetailState == rhs.pushNotificationTripDetailState
    guard areEqual else { return false }

    areEqual = lhs.databaseState == rhs.databaseState
    guard areEqual else { return false }

    areEqual = lhs.moreState == rhs.moreState
    guard areEqual else { return false }

    areEqual = lhs.transitViewState == rhs.transitViewState
    guard areEqual else { return false }

    areEqual = lhs.databaseUpdateState == rhs.databaseUpdateState
    guard areEqual else { return false }

    areEqual = lhs.notificationState == rhs.notificationState
    guard areEqual else { return false }

    return areEqual
}
