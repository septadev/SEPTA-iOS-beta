// Septa. 2017

// Septa. 2017
// SEPTA.org, created on 8/7/2017.

import XCTest
import ReSwift
@testable import Septa
import SeptaSchedule

/// SelectScheduleViewModelTests purpose: Verify that the view model updates schedules properly
class SelectScheduleViewModelTests: XCTestCase {

    enum TableRow: Int {
        case selectRoute = 0
        case selectStart = 1
        case selectEnd = 2
    }

    var scheduleRequest_NoRoute: ScheduleRequest!
    var mockController: MockController!
    var viewModel: SelectSchedulesViewModel!
    var mockCell: MockSingleCell!
    var accessoryView: CellDecoration!

    class MockController: UpdateableFromViewModel {
        var viewModelUpdatedCalled = false
        func viewModelUpdated() {
            viewModelUpdatedCalled = true
        }
    }

    override func setUp() {
        mockController = MockController()
        viewModel = SelectSchedulesViewModel(delegate: mockController)
        viewModel.unsubscribe()
        mockCell = MockSingleCell()
    }

    /// Delegate is updated when the state changes
    func testDelegateIsUpdatedWhenTheStateChanges() {
        let scheduleRequest = ScheduleRequest()
        viewModel.newState(state: scheduleRequest)
        XCTAssertTrue(mockController.viewModelUpdatedCalled)
    }

    func testSelectRouteCell_NoRouteSelected() {
        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: nil, selectedStart: nil, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectRoute.rawValue)

        XCTAssertEqual(mockCell.labelText, "Select Route")
        XCTAssertTrue(viewModel.canCellBeSelected(atRow: TableRow.selectRoute.rawValue))
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.enabledText))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.disclosureIndicator)
    }

    func testSelectRouteCell_OneRouteAvailable() {
        let route = Route(routeId: "12", routeShortName: "Go Home", routeLongName: "Home to Work")
        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: route, selectedStart: nil, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: true)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectRoute.rawValue)

        XCTAssertEqual(mockCell.labelText, "Home to Work")
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.enabledText))
        XCTAssertFalse(viewModel.canCellBeSelected(atRow: TableRow.selectRoute.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.none)
    }

    func testSelectStartCell_NoRouteSelected() {

        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: nil, selectedStart: nil, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectStart.rawValue)

        XCTAssertEqual(mockCell.labelText, SeptaString.SelectStart)
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.disabledText))
        XCTAssertFalse(viewModel.canCellBeSelected(atRow: TableRow.selectStart.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.none)
    }

    func testSelectStartCell_NoStartSelected() {
        let route = Route(routeId: "12", routeShortName: "Go Home", routeLongName: "Home to Work")
        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: route, selectedStart: nil, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectStart.rawValue)

        XCTAssertEqual(mockCell.labelText, SeptaString.SelectStart)
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.disabledText))
        XCTAssertTrue(viewModel.canCellBeSelected(atRow: TableRow.selectStart.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.disclosureIndicator)
    }

    func testSelectStartCell_StartSelected() {
        let route = Route(routeId: "12", routeShortName: "Go Home", routeLongName: "Home to Work")
        let start = Stop(stopId: 12, stopName: "Stop 12", stopLatitude: 13, stopLongitude: 14, wheelchairBoarding: true)
        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: route, selectedStart: start, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectStart.rawValue)

        XCTAssertEqual(mockCell.labelText, "Stop 12")
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.enabledText))
        XCTAssertTrue(viewModel.canCellBeSelected(atRow: TableRow.selectStart.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.disclosureIndicator)
    }

    func testSelectEndCell_NoRouteSelected() {

        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: nil, selectedStart: nil, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectEnd.rawValue)

        XCTAssertEqual(mockCell.labelText, SeptaString.SelectEnd)
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.disabledText))
        XCTAssertFalse(viewModel.canCellBeSelected(atRow: TableRow.selectEnd.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.none)
    }

    func testSelectEndCell_NoStartSelected() {
        let route = Route(routeId: "12", routeShortName: "Go Home", routeLongName: "Home to Work")
        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: route, selectedStart: nil, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectEnd.rawValue)

        XCTAssertEqual(mockCell.labelText, SeptaString.SelectEnd)
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.disabledText))
        XCTAssertFalse(viewModel.canCellBeSelected(atRow: TableRow.selectEnd.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.none)
    }

    func testSelectEndCell_NoEndSelected() {
        let route = Route(routeId: "12", routeShortName: "Go Home", routeLongName: "Home to Work")
        let start = Stop(stopId: 12, stopName: "Stop 12", stopLatitude: 13, stopLongitude: 14, wheelchairBoarding: true)
        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: route, selectedStart: start, selectedEnd: nil, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectEnd.rawValue)

        XCTAssertEqual(mockCell.labelText, SeptaString.SelectEnd)
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.disabledText))
        XCTAssertTrue(viewModel.canCellBeSelected(atRow: TableRow.selectEnd.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.disclosureIndicator)
    }

    func testSelectEndCell_EndSelected() {
        let route = Route(routeId: "12", routeShortName: "Go Home", routeLongName: "Home to Work")
        let start = Stop(stopId: 12, stopName: "Stop 125", stopLatitude: 13, stopLongitude: 14, wheelchairBoarding: true)
        let end = Stop(stopId: 12, stopName: "Stop 45", stopLatitude: 13, stopLongitude: 14, wheelchairBoarding: true)
        scheduleRequest_NoRoute = ScheduleRequest(selectedRoute: route, selectedStart: start, selectedEnd: end, transitMode: nil, onlyOneRouteAvailable: false)
        viewModel.newState(state: scheduleRequest_NoRoute)
        viewModel.configureDisplayable(mockCell, atRow: TableRow.selectEnd.rawValue)

        XCTAssertEqual(mockCell.labelText, "Stop 45")
        XCTAssertTrue(mockCell.textColor.isEqual(SeptaColor.enabledText))
        XCTAssertTrue(viewModel.canCellBeSelected(atRow: TableRow.selectEnd.rawValue))
        XCTAssertEqual(mockCell.accessoryType, CellDecoration.disclosureIndicator)
    }
}
