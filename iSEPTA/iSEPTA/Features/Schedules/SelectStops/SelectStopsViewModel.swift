// SEPTA.org, created on 8/1/17.

import Foundation
import SeptaSchedule

class SelectStopsViewModel {
    private typealias ViewElement = SelectedStopViewElement

    // These two are like like view models just for each row
    private var startElement = ViewElement.buildViewElement(forType: .noStartSelected, withStop: nil)
    private var destinationElement = ViewElement.buildViewElement(forType: .noDestinationSelected, withStop: nil)

    private weak var delegate: UpdateableFromViewModel?
    var routeType: RouteType
    var route: Route

    // The model element that totall determins ehter or not
    var routeStops = RouteStops(startStop: nil, destinationStop: nil) {
        didSet {
            let startType: SelectedStopType = routeStops.startStop == nil ? .noStartSelected : .startSelected
            let destinationType: SelectedStopType = routeStops.destinationStop == nil ? .noDestinationSelected : .destinationSelected

            startElement = ViewElement.buildViewElement(forType: startType, withStop: routeStops.startStop)
            destinationElement = ViewElement.buildViewElement(forType: destinationType, withStop: routeStops.destinationStop)
            delegate?.viewModelUpdated()
        }
    }

    init(routeType: RouteType, route: Route, delegate: UpdateableFromViewModel) {
        self.routeType = routeType
        self.route = route
        self.delegate = delegate
    }

    func canUserContinue() -> Bool {
        return routeStops.isComplete
    }

    var selectedRow: SelectStopRow = .selectStart

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        guard let row = SelectStopRow(rawValue: row) else { return }
        switch row {
        case .selectStart:
            displayable.setLabelText(text: startElement.labelText)
        case .selectDestination:
            displayable.setLabelText(text: destinationElement.labelText)
        }
    }

    func cellIdentifierAtRow(_ row: Int) -> String? {
        guard let row = SelectStopRow(rawValue: row) else { return nil }
        switch row {
        case .selectStart:
            return startElement.cellType.rawValue
        case .selectDestination:
            return destinationElement.cellType.rawValue
        }
    }
}
