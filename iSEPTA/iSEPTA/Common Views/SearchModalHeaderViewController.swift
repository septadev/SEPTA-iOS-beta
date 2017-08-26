//
//  SearchModalHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/25/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class SearchModalHeaderViewController: UIViewController {

    @IBOutlet weak var dismissIcon: UIView!
    @IBOutlet weak var searchByTextView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchByTextView.layer.cornerRadius = 3.0
        searchByTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchByTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
    }
    @IBAction func didTapDismiss(_ sender: Any) {
    }
}
