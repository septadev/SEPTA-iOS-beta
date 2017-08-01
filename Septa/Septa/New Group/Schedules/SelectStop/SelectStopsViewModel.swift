// SEPTA.org, created on 8/1/17.

import Foundation
import SeptaSchedule

fileprivate typealias My = SelectedStopViewElement

enum SelectStopsCellType: String {
    case noSelectionCell
    case stopCell
}

enum SelectedStopType {

    case noStartSelected
    case noDestinationSelected
    case startSelected
    case destinationSelected
}

struct SelectedStopViewElement {

    private static let noStartString = "Select a starting Stop"
    private static let noStopString = "Select an ending Stop"

    let cellType: SelectStopsCellType
    let labelText: String?
    let stop: Stop?

    static func buildViewElement(forType stopType: SelectedStopType, withStop stop: Stop?) -> SelectedStopViewElement {
        switch stopType {
        case .noStartSelected:
            return SelectedStopViewElement(cellType: .noSelectionCell, labelText: My.noStartString, stop: nil)
        case .noDestinationSelected:
            return SelectedStopViewElement(cellType: .noSelectionCell, labelText: My.noStopString, stop: nil)
        case .startSelected:
            return SelectedStopViewElement(cellType: .stopCell, labelText: stop?.stopName, stop: stop)
        case .destinationSelected:
            return SelectedStopViewElement(cellType: .stopCell, labelText: stop?.stopName, stop: stop)
        }
    }
}

class SelectStopsViewModel {
    private typealias ViewElement = SelectedStopViewElement
    private weak var delegate: ViewModelUpdateable?

    private var startElement = ViewElement.buildViewElement(forType: .noStartSelected, withStop: nil)

    private var endElement = ViewElement.buildViewElement(forType: .noDestinationSelected, withStop: nil)

    func shouldEnableContinueButton() -> Bool {
        return startElement.stop != nil && endElement.stop != nil
    }

    func setStartStop(_ stop: Stop) {
        startElement = ViewElement.buildViewElement(forType: .startSelected, withStop: stop)
        delegate?.viewModelUpdated()
    }

    func setDestinationStop(_ stop: Stop) {
        endElement = ViewElement.buildViewElement(forType: .destinationSelected, withStop: stop)
        delegate?.viewModelUpdated()
    }

    init(delegate: ViewModelUpdateable, routeType _: RouteType) {
        self.delegate = delegate
    }
}
