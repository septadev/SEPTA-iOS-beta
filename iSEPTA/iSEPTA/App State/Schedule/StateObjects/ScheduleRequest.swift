// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleRequest {

    let transitMode: TransitMode
    let selectedRoute: Route?
    let selectedStart: Stop?
    let selectedEnd: Stop?
    let scheduleType: ScheduleType?
    let reverseStops: Bool

    init(transitMode: TransitMode = TransitMode.defaultTransitMode(), selectedRoute: Route? = nil, selectedStart: Stop? = nil, selectedEnd: Stop? = nil, scheduleType: ScheduleType? = nil, reverseStops: Bool = false) {
        self.transitMode = transitMode
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd
        self.scheduleType = scheduleType
        self.reverseStops = reverseStops
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

    return areEqual
}

extension ScheduleRequest {

    func convertedToFavorite() -> Favorite? {
        guard
            let selectedRoute = selectedRoute,
            let selectedStart = selectedStart,
            let selectedEnd = selectedEnd else { return nil }
        let favoriteId = UUID().uuidString
        let routeName = selectedRoute.routeId == Route.allRailRoutesRouteId() ? "Rail" : selectedRoute.routeId
        let favoriteName = "\(routeName): \(selectedStart.stopName) to \(selectedEnd.stopName)"
        return Favorite(favoriteId: favoriteId, favoriteName: favoriteName, transitMode: transitMode, selectedRoute: selectedRoute, selectedStart: selectedStart, selectedEnd: selectedEnd, nextToArriveTrips: [NextToArriveTrip](), nextToArriveUpdateStatus: .idle, refreshDataRequested: true)
    }

    func locateInFavorites() -> Favorite? {
        guard
            let selectedRoute = selectedRoute,
            let selectedStart = selectedStart,
            let selectedEnd = selectedEnd else { return nil }
        let favorites = store.state.favoritesState.favorites
        if let favorite = favorites.filter({
            $0.transitMode == transitMode &&
                $0.selectedRoute == selectedRoute &&
                $0.selectedStart == selectedStart &&
                $0.selectedEnd == selectedEnd }).first {
            return favorite
        } else {
            return nil
        }
    }
}
