// Septa. 2017

import UIKit
import ReSwift

class NextToArriveViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = AddressLookupState
    @IBOutlet weak var toolbar: UIToolbar!

    @IBAction func LocationButtonTapped(_: Any) {

        store.dispatch(RequestLocation())
    }

    @IBOutlet weak var nextToArriveLabel: UILabel!

    override func viewDidLoad() {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.addressLookupState
            }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if let placemark = state.searchResults.first {
            guard let name = placemark.name, let locality = placemark.locality, let state = placemark.administrativeArea, let zip = placemark.postalCode else { return }
            nextToArriveLabel.text = "\(name) \(locality) \(state) \(zip)   "
        }
    }
}
