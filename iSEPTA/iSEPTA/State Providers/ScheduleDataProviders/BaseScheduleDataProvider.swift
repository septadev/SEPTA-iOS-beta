// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class BaseScheduleDataProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest
    var currentScheduleRequest = ScheduleRequest()

    func newState(state: StoreSubscriberStateType) {
        let scheduleRequest = state
        guard currentScheduleRequest != scheduleRequest else { return }
        print("New State in Schedule Data Provider")
        processReverseTrip(scheduleRequest: scheduleRequest)
        processSelectedRoute(scheduleRequest: scheduleRequest)
        processSelectedTripStart(scheduleRequest: scheduleRequest)
        processSelectedTripEnd(scheduleRequest: scheduleRequest)
        processSelectedTrip(scheduleRequest: scheduleRequest)

        currentScheduleRequest = scheduleRequest
    }

    func processSelectedRoute(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForRoutes(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForRoutesHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveAvailableRoutes(scheduleRequest: scheduleRequest)
        }
    }

    func processSelectedTripStart(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForTripStarts(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForTripStartsHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveStartingStopsForRoute(scheduleRequest: scheduleRequest)
        }
    }

    func processSelectedTripEnd(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForTripEnds(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForTripEndsHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveEndingStopsForRoute(scheduleRequest: scheduleRequest)
        }
    }

    func processSelectedTrip(scheduleRequest: ScheduleRequest) {
        let prereqsExist = prerequisitesExistForTrips(scheduleRequest: scheduleRequest)
        let prereqsChanged = prerequisitesForTripsHaveChanged(scheduleRequest: scheduleRequest)

        if prereqsExist && prereqsChanged {

            retrieveTripsForRoute(scheduleRequest: scheduleRequest)
        }
    }

    func processReverseTrip(scheduleRequest: ScheduleRequest) {
        if scheduleRequest.reverseStops == true {
            reverseTrip(scheduleRequest: scheduleRequest)
        }
    }

    // MARK: - Prerequisites Exist

    func prerequisitesExistForRoutes(scheduleRequest: ScheduleRequest) -> Bool {
        return scheduleRequest.transitMode != nil && scheduleRequest.databaseIsLoaded
    }

    func prerequisitesExistForTripStarts(scheduleRequest: ScheduleRequest) -> Bool {
        return scheduleRequest.transitMode != nil &&
            scheduleRequest.selectedRoute != nil
    }

    func prerequisitesExistForTripEnds(scheduleRequest: ScheduleRequest) -> Bool {
        return scheduleRequest.transitMode != nil &&
            scheduleRequest.selectedRoute != nil &&
            scheduleRequest.selectedStart != nil
    }

    func prerequisitesExistForTrips(scheduleRequest: ScheduleRequest) -> Bool {
        return scheduleRequest.transitMode != nil &&
            scheduleRequest.selectedRoute != nil &&
            scheduleRequest.selectedStart != nil &&
            scheduleRequest.selectedEnd != nil &&
            scheduleRequest.scheduleType != nil
    }

    // MARK: -  Prerequisites Have Changed

    func prerequisitesForRoutesHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let transitModeComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.transitMode, newValue: scheduleRequest.transitMode)
        let databaseIsLoadedComparison = currentScheduleRequest.databaseIsLoaded == scheduleRequest.databaseIsLoaded

        let prereqsHaveChanged = !transitModeComparison.equalityResult() || !databaseIsLoadedComparison
        return prereqsHaveChanged
    }

    func prerequisitesForTripStartsHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedRoute, newValue: scheduleRequest.selectedRoute)
        return !comparisonResult.equalityResult()
    }

    func prerequisitesForTripEndsHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let comparisonResult = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedStart, newValue: scheduleRequest.selectedStart)
        return !comparisonResult.equalityResult()
    }

    func prerequisitesForTripsHaveChanged(scheduleRequest: ScheduleRequest) -> Bool {
        let selectedEndComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.selectedEnd, newValue: scheduleRequest.selectedEnd)
        let scheduleTypeComparison = Optionals.optionalCompare(currentValue: currentScheduleRequest.scheduleType, newValue: scheduleRequest.scheduleType)
        return !selectedEndComparison.equalityResult() || !scheduleTypeComparison.equalityResult()
    }

    // MARK: - Clear out existing data
    func clearRoutes() {
    }

    func clearStartingStops() {
    }

    func clearEndingStops() {
    }

    func clearTrips() {
    }

    // MARK: - Retrieve Data

    func retrieveAvailableRoutes(scheduleRequest _: ScheduleRequest) {
    }

    func retrieveStartingStopsForRoute(scheduleRequest _: ScheduleRequest) {
    }

    func retrieveEndingStopsForRoute(scheduleRequest _: ScheduleRequest) {
    }

    func retrieveTripsForRoute(scheduleRequest _: ScheduleRequest) {
    }

    // MARK: - Reverse Trip

    func reverseTrip(scheduleRequest _: ScheduleRequest) {
    }

    deinit {
        store.unsubscribe(self)
    }
}
