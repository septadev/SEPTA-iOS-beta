// Septa. 2017

import Foundation
import SeptaSchedule

struct SelectedStopViewElement {
    fileprivate typealias My = SelectedStopViewElement
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
