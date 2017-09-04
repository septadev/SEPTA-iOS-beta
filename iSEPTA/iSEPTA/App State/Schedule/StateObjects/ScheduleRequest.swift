// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleRequest {

    let transitMode: TransitMode?
    let selectedRoute: Route?
    let selectedStart: Stop?
    let selectedEnd: Stop?
    let scheduleType: ScheduleType?
    let reverseStops: Bool
    let databaseIsLoaded: Bool

    init(transitMode: TransitMode? = nil, selectedRoute: Route? = nil, selectedStart: Stop? = nil, selectedEnd: Stop? = nil, scheduleType: ScheduleType? = nil, reverseStops: Bool = false, databaseIsLoaded: Bool = false) {
        self.transitMode = transitMode
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
        self.scheduleType = scheduleType
        self.reverseStops = reverseStops
        self.databaseIsLoaded = databaseIsLoaded
    }
}

extension ScheduleRequest: Equatable {}
func ==(lhs: ScheduleRequest, rhs: ScheduleRequest) -> Bool {
    var areEqual = true

    areEqual = Optionals.optionalCompare(currentValue: lhs.transitMode, newValue: rhs.transitMode).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.selectedRoute, newValue: rhs.selectedRoute).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.selectedStart, newValue: rhs.selectedStart).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.selectedEnd, newValue: rhs.selectedEnd).equalityResult()
    guard areEqual else { return false }

    areEqual = Optionals.optionalCompare(currentValue: lhs.scheduleType, newValue: rhs.scheduleType).equalityResult()
    guard areEqual else { return false }

    areEqual = lhs.reverseStops == rhs.reverseStops
    guard areEqual else { return false }

    areEqual = lhs.databaseIsLoaded == rhs.databaseIsLoaded
    guard areEqual else { return false }

    return areEqual
}

extension ScheduleRequest {

    func convertedToFavorite() -> Favorite? {
        guard let transitMode = transitMode,
            let selectedRoute = selectedRoute,
            let selectedStart = selectedStart,
            let selectedEnd = selectedEnd else { return nil }
        return Favorite(transitMode: transitMode, selectedRoute: selectedRoute, selectedStart: selectedStart, selectedEnd: selectedEnd)
    }

    func isFavorited() -> Bool {
        guard let favorite = self.convertedToFavorite() else { return false }
        return store.state.favoritesState.favorites.contains(favorite)
    }
}
