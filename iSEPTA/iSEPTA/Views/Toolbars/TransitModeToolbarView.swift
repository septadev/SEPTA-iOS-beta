// Septa. 2017

import Foundation
import UIKit

@IBDesignable
class TransitModeToolbarView: UIView {
    @IBInspectable var highlighted: Bool = false
    @IBInspectable var title: String = "TransitMode"
    @IBInspectable var id: String = "bus"
    var transitMode: TransitMode? { return TransitMode(rawValue: id) }

    override func draw(_ rect: CGRect) {
        backgroundColor = nil
        SeptaDraw.drawTranssitModeToolbar(frame: rect, transitMode: title, highlighted: highlighted)
    }
}
