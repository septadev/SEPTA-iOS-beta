// Septa. 2017

import Foundation
import SeptaSchedule

struct ScheduleRequest: Equatable {
    let transitMode: TransitMode
    var selectedRoute: Route?
    let selectedStart: Stop?
    let selectedEnd: Stop?
    let scheduleType: ScheduleType?
    let reverseStops: Bool

    init(transitMode: TransitMode = TransitMode.defaultTransitMode(), selectedRoute: Route? = nil, selectedStart: Stop? = nil, selectedEnd: Stop? = nil, scheduleType: ScheduleType? = nil, reverseStops: Bool = false) {
        self.transitMode = transitMode
        self.selectedRoute = selectedRoute
        self.selectedStart = selectedStart
        self.selectedEnd = selectedEnd

        self.reverseStops = reverseStops
        if scheduleType == nil {
            self.scheduleType = ScheduleType.defaultScheduleType(transitMode: transitMode)
        } else {
            self.scheduleType = scheduleType
        }
    }
}

extension ScheduleRequest {
    func convertedToFavorite(favoriteId: String? = nil) -> Favorite? {
        guard
            let selectedRoute = selectedRoute,
            let selectedStart = selectedStart,
            let selectedEnd = selectedEnd else { return nil }
        let favoriteId = favoriteId ?? UUID().uuidString
        let routeName = selectedRoute.routeId == Route.allRailRoutesRouteId() ? "Rail" : selectedRoute.routeId
        let favoriteName = "\(routeName): \(selectedStart.stopName) to \(selectedEnd.stopName)"
        return Favorite(favoriteType: .nextToArrive, favoriteId: favoriteId, favoriteName: favoriteName, transitMode: transitMode, selectedRoute: selectedRoute, selectedStart: selectedStart, selectedEnd: selectedEnd, nextToArriveTrips: [NextToArriveTrip](), nextToArriveUpdateStatus: .idle, refreshDataRequested: true)
    }

    func locateInFavorites() -> Favorite? {
        guard
            let selectedRoute = selectedRoute,
            let selectedStart = selectedStart,
            let selectedEnd = selectedEnd else { return nil }
        let favorites = store.state.favoritesState.favorites
        if let favorite = favorites.filter({
            $0.transitMode == transitMode &&
                $0.selectedRoute.routeId == selectedRoute.routeId &&
                $0.selectedStart.stopId == selectedStart.stopId &&
                $0.selectedEnd.stopId == selectedEnd.stopId }).first {
            return favorite
        } else {
            return nil
        }
    }

    func reversedScheduleRequest() -> ScheduleRequest {
        let newSelectedStart = selectedStart
        let newSelectedEnd = selectedEnd
        let newTransitMode = transitMode
        let newSelectedRoute = selectedRoute
        let newScheduleType = scheduleType
        let newReverseStops = true
        return ScheduleRequest(transitMode: newTransitMode, selectedRoute: newSelectedRoute, selectedStart: newSelectedStart, selectedEnd: newSelectedEnd, scheduleType: newScheduleType, reverseStops: newReverseStops)
    }
}
