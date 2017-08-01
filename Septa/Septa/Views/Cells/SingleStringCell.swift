// SEPTA.org, created on 8/1/17.

import UIKit

protocol SingleStringDisplayable {

    func setLabelText(text: String?)
}

class SingleStringCell: UITableViewCell, SingleStringDisplayable {
    @IBOutlet private weak var label: UILabel!

    func setLabelText(text: String?) {
        label.text = text
    }
}
