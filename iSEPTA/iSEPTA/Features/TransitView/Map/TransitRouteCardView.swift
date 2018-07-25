//
//  TransitRouteCardView.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/18/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule
import UIKit

class TransitRouteCardView: UIView {
    @IBOutlet var contentView: UIView! {
        didSet {
            contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:))))
        }
    }

    @IBOutlet var modeImage: UIImageView!
    @IBOutlet var routeIdLabel: UILabel!
    @IBOutlet var dividerLine: UIView!

    @IBOutlet var alertStackView: UIStackView! {
        didSet {
            alertStackView.isExclusiveTouch = true
        }
    }

    @IBOutlet var tappableDeleteView: UIView! {
        didSet {
            tappableDeleteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteTapped(_:))))
        }
    }

    @IBOutlet var deleteIcon: UIImageView!

    var viewModel: TransitRoute? {
        didSet {
            alpha = viewModel == nil ? 0 : 1
            enabled = false
            routeIdLabel.text = viewModel?.routeId
            modeImage.image = viewModel?.mode() == .trolley ? UIImage(named: "trolleyWhiteFinal") : UIImage(named: "busWhiteFinal")
        }
    }

    var enabled: Bool = false {
        didSet {
            layer.borderColor = enabled ? SeptaColor.segmentBlue.cgColor : UIColor.white.cgColor
            dividerLine.backgroundColor = enabled ? SeptaColor.transitViewRouteCardDividerBlue : SeptaColor.departingBoundaryOnTime // subSegmentBlue
            deleteIcon.isHidden = !enabled
            tappableDeleteView.isUserInteractionEnabled = enabled
        }
    }

    var delegate: TransitRouteCardDelegate?
    var alertsAreInteractive = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func addAlert(_ alert: SeptaAlert?) {
        alertStackView.addAlert(alert)
    }

    private func setup() {
        loadFromNib()
        alpha = 0 // Hide initially
        cornerRadius = 5
        layer.borderWidth = 1
        addStandardDropShadow()

        let alertsTappedGesture = UITapGestureRecognizer(target: self, action: #selector(alertsTapped(gr:)))
        alertStackView.addGestureRecognizer(alertsTappedGesture)
    }

    private func loadFromNib() {
        Bundle.main.loadNibNamed("TransitRouteCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    @objc func cardTapped(_: UITapGestureRecognizer) {
        guard let viewModel = viewModel else { return }
        delegate?.cardTapped(routeId: viewModel.routeId)
    }

    @objc func deleteTapped(_: UITapGestureRecognizer) {
        guard let route = viewModel else { return }

        let alert = UIAlertController(title: "Remove a Route?", message: "Would you like to remove this route from TransitView?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            store.dispatch(TransitViewRemoveRoute(route: route, description: "User wishes to remove a TransitView route from the map"))
        }))
        alert.show()
    }

    @objc func alertsTapped(gr: UITapGestureRecognizer) {
        if alertsAreInteractive {
            gr.cancelsTouchesInView = true
            let switchTabsAction = SwitchTabs(activeNavigationController: .alerts, description: "User tapped on alert from TransitView")
            store.dispatch(switchTabsAction)
        }
    }
}

protocol TransitRouteCardDelegate {
    func cardTapped(routeId: String)
}
