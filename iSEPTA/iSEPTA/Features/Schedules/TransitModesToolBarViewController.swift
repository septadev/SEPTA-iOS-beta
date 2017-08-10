// Septa. 2017

import Foundation
import UIKit
import ReSwift

class TransitModesToolbarViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = TransitMode?
    @IBOutlet var scrollbar: UIScrollView!
    @IBOutlet var transitModesToolbarElements: [TransitModeToolbarView]!
    var transitMode: TransitMode?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.600, green: 0.600, blue: 0.600, alpha: 1.000)
    }

    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    @IBAction func ToolbarTapped(_ sender: UITapGestureRecognizer) {

        guard !scrollbar.isDragging || !scrollbar.isDecelerating else { return }
        let pt = sender.location(in: sender.view)
        _ = transitModesToolbarElements.map { $0.highlighted = false }
        let hitToolbar = transitModesToolbarElements.filter {

            let contains = $0.frame.contains(pt)
            return contains
        }.first

        hitToolbar?.highlighted = true

        _ = transitModesToolbarElements.map { $0.setNeedsDisplay() }
        dispatchAction(toolbarItem: hitToolbar)
    }

    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        super.viewWillDisappear(animated)
    }

    func dispatchAction(toolbarItem: TransitModeToolbarView?) {
        guard let transitMode = toolbarItem?.transitMode else { return }

        let action = TransitModeSelected(transitMode: transitMode)
        store.dispatch(action)
        let preferenceAction = UserPreference.NewTransitModeAction(transitMode: transitMode)
        store.dispatch(preferenceAction)
    }

    func filterSubscription(state: AppState) -> TransitMode? {
        return state.scheduleState.scheduleRequest?.transitMode
    }

    func newState(state: StoreSubscriberStateType) {
        guard let transitMode = state else { fatalError("message: there should always be a transit mode") }
        intializeToolbar(transitMode: transitMode)
    }

    func intializeToolbar(transitMode: TransitMode) {

        for toolbarItem in transitModesToolbarElements {
            toolbarItem.highlighted = toolbarItem.transitMode == transitMode
        }
    }
}
