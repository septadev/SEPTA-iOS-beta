

import Foundation
import UIKit

class RouteSelectedTableViewCell: UITableViewCell {
    @IBOutlet var routeIdLabel: UILabel!
    @IBOutlet var routeShortNameLabel: UILabel!
    @IBOutlet var routeLongNameLabel: UILabel!
    @IBOutlet var pillView: UIView!

    override func awakeFromNib() {
        pillView.layer.cornerRadius = 4
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawBlueGradientCell(frame: rect, shouldFill: true, enabled: true)
    }
}
