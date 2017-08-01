// SEPTA.org, created on 8/1/17.

import UIKit

class SingleLabelCell: UITableViewCell {
    @IBOutlet private weak var label: UILabel!

    func setLabelText(text: String) {
        label.text = text
    }
}
