// Septa. 2017

import Foundation
import UIKit
import SeptaSchedule

@IBDesignable
class TransitModeToolbarView: UIView {

    @IBOutlet private weak var transitModeIconImageView: UIImageView!
    @IBOutlet private weak var transitModeLabel: UILabel!

    @IBOutlet weak var iconHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var iconWidthContraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }

    var highlighted: Bool = false {
        didSet {
            transitModeIconImageView.isHighlighted = highlighted
            iconWidthContraint.constant = highlightedSize(highlighted)
            iconHeightContraint.constant = highlightedSize(highlighted)
            self.setNeedsLayout()
        }
    }

    func highlightedSize(_ highlighted: Bool) -> CGFloat {
        return highlighted ? 40 : 20
    }

    var transitMode: TransitMode = .bus {
        didSet {
            transitModeIconImageView.image = UIImage(named: transitMode.imageName())
            transitModeIconImageView.highlightedImage = UIImage(named: transitMode.highlightedImageName())
            transitModeLabel.text = transitMode.name()
            isAccessibilityElement = true
            accessibilityLabel = transitMode.name()
        }
    }
}
