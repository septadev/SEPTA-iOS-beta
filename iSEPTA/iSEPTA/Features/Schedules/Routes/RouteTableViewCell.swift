// Septa. 2017

import UIKit

protocol RouteCellDisplayable {
    func setShortName(text: String)
    func setLongName(text: String)
    func setIcon(image: UIImage)
    func addAlert(_ alert: SeptaAlert?)
}

class RouteTableViewCell: UITableViewCell, RouteCellDisplayable {

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.isExclusiveTouch = true
        }
    }

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
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                let height = NSLayoutConstraint(item: imageView,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1.0,
                                                constant: 18)
                let width = NSLayoutConstraint(item: imageView,
                                               attribute: .width,
                                               relatedBy: .equal,
                                               toItem: nil,
                                               attribute: .notAnAttribute,
                                               multiplier: 1.0,
                                               constant: 18)
                imageView.addConstraints([height, width])
                stackView.addArrangedSubview(imageView)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let gr = UITapGestureRecognizer(target: self, action: #selector(gestureReognizerTapped(gr:)))
        stackView.addGestureRecognizer(gr)
    }

    @objc func gestureReognizerTapped(gr: UITapGestureRecognizer) {
        gr.cancelsTouchesInView = true
        let dismissModalAction = DismissModal(navigationController: .schedules, description: "Dismissing the modal to switch tabs")
        store.dispatch(dismissModalAction)
        let switchTabsAction = SwitchTabs(activeNavigationController: .alerts, description: "User tapped on alert")
        store.dispatch(switchTabsAction)
    }
}
