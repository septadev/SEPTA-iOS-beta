// Septa. 2017

import UIKit

class SelectRouteCell: UITableViewCell {
}

class SingleStringCell: UITableViewCell, SingleStringDisplayable {
    var shouldFill: Bool = false
    var enabled: Bool = false
    @IBOutlet private weak var label: UILabel!
    func setTextColor(_ color: UIColor) {
        label.textColor = color
    }

    func setLabelText(_ text: String?) {
        label.text = text
    }

    func setAccessoryType(_ accessoryType: UITableViewCellAccessoryType) {
        self.accessoryType = accessoryType
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawBlueGradientCell(frame: rect, shouldFill: shouldFill, enabled: enabled)
    }

    func setShouldFill(_ shouldFill: Bool) {
        self.shouldFill = shouldFill
    }

    func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
        label.alpha = enabled ? CGFloat(0.7) : CGFloat(0.3)
        setNeedsDisplay()
    }
}
