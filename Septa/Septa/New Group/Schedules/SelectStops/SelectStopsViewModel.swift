// SEPTA.org, created on 8/1/17.

import Foundation
import SeptaSchedule

class SelectStopsViewModel {
    private typealias ViewElement = SelectedStopViewElement
    private weak var delegate: UpdateableFromViewModel?

    private var startElement = ViewElement.buildViewElement(forType: .noStartSelected, withStop: nil)

    private var destinationElement = ViewElement.buildViewElement(forType: .noDestinationSelected, withStop: nil)

    func canUserContinue() -> Bool {
        return startElement.stop != nil && destinationElement.stop != nil
    }

    func setStartStop(_ stop: Stop) {
        startElement = ViewElement.buildViewElement(forType: .startSelected, withStop: stop)
        delegate?.viewModelUpdated()
    }

    func setDestinationStop(_ stop: Stop) {
        destinationElement = ViewElement.buildViewElement(forType: .destinationSelected, withStop: stop)
        delegate?.viewModelUpdated()
    }

    func stopAtRow(_ row: Int) -> Stop? {
        guard let row = SelectStopRow(rawValue: row) else { return nil }
        switch row {
        case .selectStart:
            return startElement.stop
        case .selectDestination:
            return destinationElement.stop
        }
    }

    var routeStops: RouteStops {
        return RouteStops(startStop: startElement.stop
                          , destinationStop: destinationElement.stop)
    }

    init(delegate: UpdateableFromViewModel, routeType _: RouteType) {
        self.delegate = delegate
    }

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
