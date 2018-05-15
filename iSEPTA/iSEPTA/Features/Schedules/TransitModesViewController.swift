// Septa. 2017

import SeptaSchedule
import UIKit

class TransitModesViewController: UIViewController {
    @IBOutlet var transitModeView: UIView!

    @IBOutlet var scrollbar: UIScrollView!

    @IBOutlet var transitModesToolbarElements: [TransitModeToolbarView]!
    override func viewDidLoad() {

        view.backgroundColor = UIColor(red: 0.600, green: 0.600, blue: 0.600, alpha: 1.000)
    }

    override func viewWillAppear(_: Bool) {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.backgroundColor = UIColor.clear
        navBar.shadowImage = UIImage()
        navBar.setBackgroundImage(UIImage(), for: .default)
    }

    @IBAction func toolbarTapped(_ gr: UITapGestureRecognizer) {

        guard !scrollbar.isDragging || !scrollbar.isDecelerating else { return }
        let pt = gr.location(in: gr.view)
        _ = transitModesToolbarElements.map { $0.highlighted = false }
        let hitToolbar = transitModesToolbarElements.filter {

            let contains = $0.frame.contains(pt)
            return contains
        }.first

        hitToolbar?.highlighted = true

        _ = transitModesToolbarElements.map { $0.setNeedsDisplay() }

        let action = TransitModeSelected(transitMode: hitToolbar?.transitMode)
        store.dispatch(action)
    }
}
