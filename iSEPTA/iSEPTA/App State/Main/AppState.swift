// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

struct AppState: StateType {
    let navigationState: NavigationState
    let scheduleState: ScheduleState
    let preferenceState: UserPreferenceState
    let alertState: AlertState
    let addressLookupState: AddressLookupState
    let locationState: LocationState
    let favoritesState: FavoritesState
    let nextToArriveState: NextToArriveState
    let tripDetailState: TripDetailState
    let databaseState: DatabaseState
    let moreState: MoreState
    let transitViewState: TransitViewState
    let databaseUpdateState: DatabaseUpdateState

    init(navigationState: NavigationState, scheduleState: ScheduleState, preferenceState: UserPreferenceState, alertState: AlertState, addressLookupState: AddressLookupState, locationState: LocationState, favoriteState: FavoritesState, nextToArriveState: NextToArriveState, tripDetailState: TripDetailState, databaseState: DatabaseState, moreState: MoreState, transitViewState: TransitViewState, databaseUpdateState: DatabaseUpdateState) {
        self.navigationState = navigationState
        self.scheduleState = scheduleState
        self.preferenceState = preferenceState
        self.alertState = alertState
        self.addressLookupState = addressLookupState
        self.locationState = locationState
        favoritesState = favoriteState
        self.nextToArriveState = nextToArriveState
        self.tripDetailState = tripDetailState
        self.databaseState = databaseState
        self.moreState = moreState
        self.transitViewState = transitViewState
        self.databaseUpdateState = databaseUpdateState
    }
}
