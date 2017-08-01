// SEPTA.org, created on 8/1/17.

import Foundation
import SeptaSchedule

fileprivate typealias My = SelectedStopViewElement

enum SelectStopsCellType: String {
    case noSelectionCell
    case stopCell
}

enum SelectStopRow: Int {
    case selectStart = 0
    case selectDestination = 1
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
