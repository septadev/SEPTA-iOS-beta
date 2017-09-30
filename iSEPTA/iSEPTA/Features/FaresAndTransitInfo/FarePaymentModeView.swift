//
//  FarePaymentModeView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/28/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class FarePaymentModeView: UIView {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    var septaConnection: SEPTAConnection? {
        didSet {
            guard let _ = septaConnection else { return }
            tapGestureRecognizer.isEnabled = true
            descriptionLabel.isUserInteractionEnabled = true
        }
    }

    @IBAction func didTapDescription(_: Any) {
        guard let septaConnection = septaConnection else { return }
        let moreAction = MakeSeptaConnection(septaConnection: septaConnection)
        store.dispatch(moreAction)
    }
}
