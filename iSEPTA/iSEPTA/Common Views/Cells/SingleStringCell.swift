// Septa. 2017

import UIKit

class SingleStringCell: UITableViewCell, SingleStringDisplayable {
    var shouldFill: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    var enabled: Bool = false
    @IBOutlet var label: UILabel!
    func setTextColor(_ color: UIColor) {
        label.textColor = color
    }

    @IBOutlet var searchIcon: UIImageView!
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
        if let searchIcon = searchIcon {
            searchIcon.alpha = enabled ? CGFloat(0.7) : CGFloat(0.3)
        }
        setNeedsDisplay()
    }
}
