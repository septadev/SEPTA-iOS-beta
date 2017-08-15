// Septa. 2017

import UIKit



typealias CellDecoration = UITableViewCellAccessoryType

class SingleStringCell: UITableViewCell, SingleStringDisplayable {

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
}
