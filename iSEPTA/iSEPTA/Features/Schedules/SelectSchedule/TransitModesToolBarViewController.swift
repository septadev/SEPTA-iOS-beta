// Septa. 2017

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

class TransitModesToolbarViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = TransitMode?
    @IBOutlet var scrollbar: UIScrollView!
    var transitModesToolbarElements = [TransitModeToolbarView]()

    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        buildToolbar()
    }

    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    func subscribe() {

        store.subscribe(self) { subscription in
            subscription.select {
                $0.scheduleState.scheduleRequest?.transitMode
            }.skipRepeats { $0 == $1 }
        }
    }

    func buildToolbar() {
        transitModesToolbarElements.removeAll()
        for transitMode in TransitMode.displayOrder() {
            let toolbarView: TransitModeToolbarView = UIView.instanceFromNib(named: "TransitModeToolBarView")
            toolbarView.transitMode = transitMode
            transitModesToolbarElements.append(toolbarView)
            stackView.addArrangedSubview(toolbarView)
        }
    }

    func intializeToolbar(transitMode: TransitMode) {

        for toolbarItem in transitModesToolbarElements {
            toolbarItem.highlighted = toolbarItem.transitMode == transitMode
        }
        makeSelectedToolbarItemVisible()
    }

    func makeSelectedToolbarItemVisible() {
        guard let selectedToolBarItem = selectedToolBar() else { return }

        let rightEdgeOfSelectedItem = mapCGPointFromToolbar(toolBar: selectedToolBarItem)
        let scrollBarWidth = scrollbar.frame.size.width
        let amountToMove = rightEdgeOfSelectedItem - scrollBarWidth

        if amountToMove > CGFloat(0) {
            UIView.animate(withDuration: 0.35) { [weak self] in
                self?.scrollbar.contentOffset = CGPoint(x: amountToMove, y: 0)
            }
        }
    }

    func selectedToolBar() -> TransitModeToolbarView? {
        let selected = transitModesToolbarElements.filter(isSelectedToolbar)
        return selected.first
    }

    func isSelectedToolbar(toolBar: TransitModeToolbarView) -> Bool {
        return toolBar.highlighted
    }

    func mapCGPointFromToolbar(toolBar: TransitModeToolbarView) -> CGFloat {
        let itemFrame = toolBar.frame
        return itemFrame.origin.x + itemFrame.size.width
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

        let action = TransitModeSelected(transitMode: transitMode, description: "User switched the transit mode toolbar")
        store.dispatch(action)
        let preferenceAction = NewTransitModeAction(transitMode: transitMode)
        store.dispatch(preferenceAction)
    }

    func newState(state: StoreSubscriberStateType) {
        guard let transitMode = state else { fatalError("message: there should always be a transit mode") }

        intializeToolbar(transitMode: transitMode)
    }
}
