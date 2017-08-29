// Septa. 2017

import UIKit

protocol RouteCellDisplayable {
    func setShortName(text: String)
    func setLongName(text: String)
    func setIcon(image: UIImage)
}

class RouteTableViewCell: UITableViewCell, RouteCellDisplayable {

    @IBOutlet private weak var routeShortNameLabel: UILabel!
    @IBOutlet private weak var routeLongNameLabel: UILabel!

    @IBOutlet private weak var iconImageView: UIImageView!
    func setShortName(text: String) {
        routeShortNameLabel.text = text
    }

    func setLongName(text: String) {
        routeLongNameLabel.text = text
    }

    func setIcon(image: UIImage) {
        iconImageView.image = image
    }
}
