// SEPTA.org, created on 8/1/17.

import UIKit

protocol RouteCellDisplayable {
    func setShortName(text: String)
    func setLongName(text: String)
}

class RouteTableViewCell: UITableViewCell, RouteCellDisplayable {

    @IBOutlet weak var routeShortNameLabel: UILabel!
    @IBOutlet weak var routeLongNameLabel: UILabel!

    func setShortName(text: String) {
        routeShortNameLabel.text = text
    }

    func setLongName(text: String) {
        routeLongNameLabel.text = text
    }
}
