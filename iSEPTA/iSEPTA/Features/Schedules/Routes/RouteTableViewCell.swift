// Septa. 2017

import UIKit

protocol RouteCellDisplayable {
    func setShortName(text: String)
    func setLongName(text: String)
    func setIcon(image: UIImage)
    func addAlert(_ alert: SeptaAlert?)
}

class RouteTableViewCell: UITableViewCell, RouteCellDisplayable {

    @IBOutlet weak var stackView: UIStackView!
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

    func addAlert(_ alert: SeptaAlert?) {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        if let alert = alert {
            let imageViews = alert.imagesForAlert().map {
                UIImageView(image: $0)
            }
            for imageView in imageViews {
                stackView.addArrangedSubview(imageView)
            }
        }
    }
}
