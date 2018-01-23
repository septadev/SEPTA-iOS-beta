//
//  ScheduleTransitModesToolBarViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class ScheduleTransitModesToolBarViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = TransitMode?
    @IBOutlet var scrollbar: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    var currentTransitMode: TransitMode?
    var targetForScheduleAction: TargetForScheduleAction! { return store.state.targetForScheduleActions() }
    var transitModesToolbarElements = [TransitModeToolbarView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        buildToolbar()
    }

    func buildToolbar() {
        transitModesToolbarElements.removeAll()
        for transitMode in TransitMode.displayOrder() {
            let toolbarView: TransitModeToolbarView = UIView.instanceFromNib(named: "TransitModeToolBarView")
            toolbarView.transitMode = transitMode
            toolbarView.isAccessibilityElement = true
            toolbarView.accessibilityLabel = transitMode.name()
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

    func dispatchAction(toolbarItem: TransitModeToolbarView?) {
        guard let newTransitMode = toolbarItem?.transitMode, let currentTransitMode = currentTransitMode else { return }
        if currentTransitMode != newTransitMode {
            let action = TransitModeSelected(targetForScheduleAction: targetForScheduleAction, transitMode: newTransitMode, description: "User switched the transit mode toolbar")
            store.dispatch(action)
            let preferenceAction = NewTransitModeAction(transitMode: newTransitMode)
            store.dispatch(preferenceAction)
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let transitMode = state else { fatalError("message: there should always be a transit mode") }
        currentTransitMode = transitMode
        intializeToolbar(transitMode: transitMode)
    }
}

extension ScheduleTransitModesToolBarViewController: SubscriberUnsubscriber {
    override func viewWillAppear(_: Bool) {
        subscribe()
    }

    func subscribe() {
        if targetForScheduleAction == .schedules {
            store.subscribe(self) { subscription in
                subscription.select {
                    $0.scheduleState.scheduleRequest.transitMode
                }.skipRepeats { $0 == $1 }
            }
        } else if targetForScheduleAction == .alerts {
            store.subscribe(self) { subscription in
                subscription.select {
                    $0.alertState.scheduleState.scheduleRequest.transitMode
                }.skipRepeats { $0 == $1 }
            }

        } else if targetForScheduleAction == .nextToArrive {
            store.subscribe(self) { subscription in
                subscription.select {
                    $0.nextToArriveState.scheduleState.scheduleRequest.transitMode
                }.skipRepeats { $0 == $1 }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        unsubscribe()
        super.viewWillDisappear(animated)
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
