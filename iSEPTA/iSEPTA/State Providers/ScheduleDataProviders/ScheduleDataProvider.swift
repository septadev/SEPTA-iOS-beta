// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class ScheduleDataProvider: BaseScheduleDataProvider {
    typealias StoreSubscriberStateType = ScheduleRequest
    static let sharedInstance = ScheduleDataProvider()

    private override init() {
        super.init()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.scheduleState.scheduleRequest }.skipRepeats { $0 == $1 }
        }
    }

    let targetForScheduleAction = TargetForScheduleAction.schedules
    // MARK: - Clear out existing data
    override func clearRoutes() {
        DispatchQueue.main.async {
            store.dispatch(ClearRoutes(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    override func clearStartingStops() {
        DispatchQueue.main.async {
            store.dispatch(ClearTripStarts(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    override func clearEndingStops() {
        DispatchQueue.main.async {
            store.dispatch(ClearTripEnds(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    override func clearTrips() {
        DispatchQueue.main.async {
            store.dispatch(ClearTrips(targetForScheduleAction: self.targetForScheduleAction))
        }
    }

    // MARK: - Retrieve Data

    override func retrieveAvailableRoutes(scheduleRequest: ScheduleRequest) {
        clearRoutes()
        RoutesCommand.sharedInstance.routes(forTransitMode: scheduleRequest.transitMode!) { routes, error in
            let routes = routes ?? [Route]()
            let routesLoadedAction = RoutesLoaded(targetForScheduleAction: self.targetForScheduleAction, routes: routes, error: error?.localizedDescription)
            store.dispatch(routesLoadedAction)
        }
    }

    override func retrieveStartingStopsForRoute(scheduleRequest: ScheduleRequest) {
        clearStartingStops()
        TripStartCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode!, forRoute: scheduleRequest.selectedRoute!) { stops, error in
            let stops = stops ?? [Stop]()
            let action = TripStartsLoaded(targetForScheduleAction: self.targetForScheduleAction, availableStarts: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    override func retrieveEndingStopsForRoute(scheduleRequest: ScheduleRequest) {
        clearEndingStops()
        TripEndCommand.sharedInstance.stops(forTransitMode: scheduleRequest.transitMode!, forRoute: scheduleRequest.selectedRoute!, tripStart: scheduleRequest.selectedStart!) { stops, error in
            let stops = stops ?? [Stop]()
            let action = TripEndsLoaded(targetForScheduleAction: self.targetForScheduleAction, availableStops: stops, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    override func retrieveTripsForRoute(scheduleRequest: ScheduleRequest) {
        clearTrips()
        TripScheduleCommand.sharedInstance.tripSchedules(forTransitMode: scheduleRequest.transitMode!, route: scheduleRequest.selectedRoute!, selectedStart: scheduleRequest.selectedStart!, selectedEnd: scheduleRequest.selectedEnd!, scheduleType: scheduleRequest.scheduleType!) { trips, error in
            let trips = trips ?? [Trip]()
            let action = TripsLoaded(targetForScheduleAction: self.targetForScheduleAction, availableTrips: trips, error: error?.localizedDescription)
            store.dispatch(action)
        }
    }

    // MARK: - Reverse Trip

    override func reverseTrip(scheduleRequest: ScheduleRequest) {

        guard let transitMode = scheduleRequest.transitMode,
            let selectedRoute = scheduleRequest.selectedRoute,
            let selectedStart = scheduleRequest.selectedStart,
            let selectedEnd = scheduleRequest.selectedEnd,
            let scheduleType = scheduleRequest.scheduleType else { return }

        let tripStopId = TripStopId(start: selectedStart.stopId, end: selectedEnd.stopId)

        StopReverseCommand.sharedInstance.reverseStops(forTransitMode: transitMode, tripStopId: tripStopId) { tripStopIds, _ in
            guard let tripStopIds = tripStopIds, let tripStopId = tripStopIds.first else { return }
            TripReverseCommand.sharedInstance.reverseTrip(forTransitMode: transitMode, tripStopId: tripStopId, scheduleType: scheduleType) { trips, _ in
                guard let reversedTrips = trips else { return }
                StopsByStopIdCommand.sharedInstance.retrieveStops(forTransitMode: transitMode, tripStopId: tripStopId) { stops, _ in
                    guard let stops = stops,
                        let newStart = stops.filter({ $0.stopId == tripStopId.start }).first,
                        let newEnd = stops.filter({ $0.stopId == tripStopId.end }).first else { return }
                    ReverseRouteCommand.sharedInstance.reverseRoute(forTransitMode: transitMode, route: selectedRoute) { routes, error in
                        guard let routes = routes, let newRoute = routes.first else { return }
                        let newScheduleRequest = ScheduleRequest(transitMode: transitMode, selectedRoute: newRoute, selectedStart: newStart, selectedEnd: newEnd, scheduleType: scheduleType, reverseStops: false, databaseIsLoaded: scheduleRequest.databaseIsLoaded)
                        let action = ReverseLoaded(targetForScheduleAction: self.targetForScheduleAction, scheduleRequest: newScheduleRequest, trips: reversedTrips, error: error?.localizedDescription)
                        store.dispatch(action)
                    }
                }
            }
        }
    }
}
