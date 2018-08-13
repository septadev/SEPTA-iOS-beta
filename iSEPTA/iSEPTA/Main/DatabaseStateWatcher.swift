// Septa. 2017

import ReSwift
import SeptaSchedule
import UIKit

class DatabaseStateWatcher: StoreSubscriber {
    typealias StoreSubscriberStateType = DatabaseState

    weak var delegate: BaseScheduleDataProvider?

    init() {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.databaseState }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let delegate = delegate else { return }
        delegate.databaseStateUpdated(state)
    }

    deinit {
        store.unsubscribe(self)
    }
}
