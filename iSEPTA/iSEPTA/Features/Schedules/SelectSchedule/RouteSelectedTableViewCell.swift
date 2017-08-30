

import Foundation
import UIKit

class RouteSelectedTableViewCell: UITableViewCell {
    @IBOutlet weak var routeIdLabel: UILabel!
    @IBOutlet weak var routeShortNameLabel: UILabel!
    @IBOutlet weak var routeLongNameLabel: UILabel!
    @IBOutlet weak var pillView: UIView!

    override func awakeFromNib() {
        pillView.layer.cornerRadius = 4
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawBlueGradientCell(frame: rect, shouldFill: false, enabled: true)
    }
}
