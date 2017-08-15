// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift

struct FilterableStop {
    let filterString: String
    let sortString: String
    let stop: Stop

    init(stop: Stop) {

        filterString = stop.stopName
        sortString = stop.stopName
        self.stop = stop
    }
}

enum StopToSelect {
    case starts
    case ends
}

class SelectStopViewModel: NSObject, StoreSubscriber, UITextFieldDelegate {
    typealias StoreSubscriberStateType = [Stop]?

    var allStops: [Stop]? {
        didSet {
            guard let allStops = allStops else { return }
            allFilterableStops = allStops.map {
                FilterableStop(stop: $0)
            }
        }
    }

    fileprivate var allFilterableStops: [FilterableStop]? {
        didSet {
            filteredStops = allFilterableStops
        }
    }

    var filteredStops: [FilterableStop]? {
        didSet {
            guard let filteredStops = filteredStops else { return }
            self.filteredStops = filteredStops.sorted {
                $0.sortString < $1.sortString
            }
        }
    }

    @IBOutlet weak var selectStopViewController: UpdateableFromViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) { subscription in
            subscription.select(self.subscribeToTripStarts)
        }
    }

    func subscribeToTripStarts(state: AppState) -> [Stop]? {
        return state.scheduleState.scheduleData?.availableStarts
    }

    func subscribeToTripEnds(state: AppState) -> [Stop]? {
        return state.scheduleState.scheduleData?.availableStops
    }

    func newState(state: StoreSubscriberStateType) {
        allStops = state
        selectStopViewController?.viewModelUpdated()
    }

    func configureDisplayable(_ displayable: SingleStringDisplayable, atRow row: Int) {
        guard let filteredStops = filteredStops, row < filteredStops.count else { return }
        let stop = filteredStops[row].stop

        displayable.setLabelText(stop.stopName)
    }

    func canCellBeSelected(atRow _: Int) -> Bool {
        return true
    }

    func rowSelected(row: Int) {
        guard let filteredStops = filteredStops, row < filteredStops.count else { return }
        let stop = filteredStops[row].stop
        store.unsubscribe(self)
        let action = TripStartSelected(selectedStart: stop)
        store.dispatch(action)
        let dismissAction = DismissModal(navigationController: .schedules, description: "Stop should be dismissed")
        store.dispatch(dismissAction)
    }

    func numberOfRows() -> Int {
        guard let filteredStops = filteredStops else { return 0 }
        return filteredStops.count
    }

    deinit {
        store.unsubscribe(self)
    }

    var filterString = ""
    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {

        guard let allFilterableStops = allFilterableStops, let swiftRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: swiftRange, with: replacementString.lowercased())
        filteredStops = allFilterableStops.filter {
            guard filterString.characters.count > 0 else { return true }
            return $0.filterString.contains(filterString)
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.selectStopViewController?.viewModelUpdated()
        }
        return true
    }
}
