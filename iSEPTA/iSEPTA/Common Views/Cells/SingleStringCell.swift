// Septa. 2017

import UIKit

typealias CellDecoration = UITableViewCellAccessoryType

class SingleStringCell: UITableViewCell, SingleStringDisplayable {
    var shouldFill: Bool = false
    func setOpacity(_ opacity: Float) {
        label.layer.opacity = opacity
    }

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
        SeptaDraw.drawBlueGradientCell(frame: rect, shouldFill: shouldFill)
    }

    func setShouldFill(_ shouldFill: Bool) {
        self.shouldFill = shouldFill
    }
}
