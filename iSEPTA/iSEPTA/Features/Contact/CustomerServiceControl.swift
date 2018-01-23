//
//  CustomerServiceCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomerServiceControl: UIControl {

    var controlHighlighted = false

    @IBOutlet var iconImageView: UIImageView!

    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var connectLabelText: UILabel!
    var septaConnection: SEPTAConnection?
    var showChevron: Bool = false

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 44)
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawCustomerServiceCell(frame: rect, buttonHighlighted: controlHighlighted, showChevron: showChevron)
    }

    func displayContactPoint(_ contactPoint: ContactPoint) {
        iconImageView.image = UIImage(named: contactPoint.imageName)
        connectLabelText.text = contactPoint.septaConnection?.title()
        phoneNumberLabel.text = contactPoint.septaConnection?.formattedLink()
        showChevron = contactPoint.showChevron
        septaConnection = contactPoint.septaConnection
        setNeedsDisplay()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        controlHighlighted = true
        setNeedsDisplay()
        makeSeptaConnection()
        return true
    }

    private func makeSeptaConnection() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            guard let strongSelf = self, let septaConnection = strongSelf.septaConnection else { return }

            let action = MakeSeptaConnection(septaConnection: septaConnection)
            store.dispatch(action)

            strongSelf.controlHighlighted = false
            strongSelf.setNeedsDisplay()
        }
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        controlHighlighted = false
        setNeedsDisplay()
    }
}
