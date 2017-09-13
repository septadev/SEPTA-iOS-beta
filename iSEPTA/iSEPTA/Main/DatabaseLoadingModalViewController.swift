//
//  DatabaseLoadingModal.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

class DatabaseLoadingModalViewController: UIViewController, StoreSubscriber {

    typealias StoreSubscriberStateType = DatabaseState

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.databaseState }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if state == .loaded {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if store.state.databaseState == .loaded {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
