//
//  InstructionsHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/1/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class InstructionsHeaderView: UIView {
    @IBOutlet var instructionsLabel: UILabel! {
        didSet {
            guard let text = instructionsLabel.text else { return }
            instructionsLabel.attributedText = text.attributed(
                fontSize: 14,
                fontWeight: .regular,
                textColor: SeptaColor.black87,
                alignment: .center,
                kerning: 0.1,
                lineHeight: 20
            )
        }
    }
}
