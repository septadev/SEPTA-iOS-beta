// Septa. 2017

import Foundation
import UIKit
import ReSwift

class TransitModesToolbarViewController: UIViewController {

    @IBOutlet weak var scrollbar: UIScrollView!
    @IBOutlet var transitModesToolbarElements: [TransitModeToolbarView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.600, green: 0.600, blue: 0.600, alpha: 1.000)
        intializeToolbar()
    }

    func intializeToolbar() {

        guard let preferredTransitMode = store.state.scheduleState.scheduleRequest?.transitMode else { return }
        for toolbarItem in transitModesToolbarElements {
            toolbarItem.highlighted = toolbarItem.transitMode == preferredTransitMode
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

    func dispatchAction(toolbarItem: TransitModeToolbarView?) {
        guard let transitMode = toolbarItem?.transitMode else { return }

        let action = ScheduleActions.TransitModeSelected(transitMode: transitMode)
        store.dispatch(action)
        let preferenceAction = UserPreference.NewTransitModeAction(transitMode: transitMode)
        store.dispatch(preferenceAction)
    }
}
