// Septa. 2017

import UIKit

protocol SingleStringDisplayable {
    func setTextColor(color: UIColor)
    func setLabelText(text: String?)
}

class SingleStringCell: UITableViewCell, SingleStringDisplayable {
    @IBOutlet private weak var label: UILabel!
    func setTextColor(color: UIColor) {
        label.textColor = color
    }

    func setLabelText(text: String?) {
        label.text = text
    }
}
