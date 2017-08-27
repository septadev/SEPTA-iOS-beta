// Septa. 2017

import Foundation
import SeptaSchedule
import ReSwift
import CoreLocation
import UIKit

struct FilterableStop {
    let filterString: String
    let sortString: String
    let stop: Stop

    init(stop: Stop) {

        filterString = "\(stop.stopName.lowercased())_\(stop.stopId)"
        sortString = stop.stopName.lowercased()
        self.stop = stop
    }
}

enum StopToSelect: Int {
    case starts = 1
    case ends = 2
}

class SelectStopViewModel: NSObject, StoreSubscriber, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    typealias StoreSubscriberStateType = [Stop]?

    var stopToSelect: StopToSelect = .starts {
        didSet {
            subscribe()
        }
    }

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

    let cellId = "stopCell"

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        let rowCount = numberOfRows()
        guard let delegate = selectStopViewController else { return 0 }
        let animating = rowCount == 0
        delegate.updateActivityIndicator(animating: animating)
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SelectStopCell else { return UITableViewCell() }

        configureDisplayable(cell, atRow: indexPath.row)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowSelected(row: indexPath.row)
    }

    func subscribe() {
        if stopToSelect == .starts {
            store.subscribe(self) {
                $0.select {
                    $0.scheduleState.scheduleData?.availableStarts
                }
            }
        } else {
            store.subscribe(self) {
                $0.select {
                    $0.scheduleState.scheduleData?.availableStops
                }
            }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    func newState(state: StoreSubscriberStateType) {
        allStops = state
        guard let state = state, state.count > 0 else { return }
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
        if stopToSelect == .starts {
            let action = TripStartSelected(selectedStart: stop)
            store.dispatch(action)
        } else {
            let action = TripEndSelected(selectedEnd: stop)
            store.dispatch(action)
        }
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
        print(filterString)
        filteredStops = allFilterableStops.filter {
            guard filterString.characters.count > 0 else { return true }

            return $0.filterString.contains(filterString)
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.selectStopViewController?.viewModelUpdated()
        }
        if filterString.count > 4 {
            geoCodeFilterString()
        }
        return true
    }

    let geoCoder = CLGeocoder()

    func geoCodeFilterString() {
        geoCoder.geocodeAddressString(filterString) { placemarks, _ in
            guard let placemarks = placemarks else { return }
            for placemark in placemarks {
                print(placemark)
            }
            print("-----------")
        }
    }
}
