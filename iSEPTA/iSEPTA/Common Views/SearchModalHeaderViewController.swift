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
    weak var delegate: SearchModalHeaderDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            // textField.delegate = delegate.delegateForTextField()
        }
    }

    @IBOutlet weak var viewHeightConstraintForAddress: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraintForStops: NSLayoutConstraint!

    @IBOutlet weak var textField: UITextField!
    var searchMode: SearchMode = .directLookup {
        didSet {
            toggleHeightContraintsForSearchMode()
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var searchView: CurvedTopView!
    @IBOutlet weak var dismissIcon: UIView!
    @IBOutlet weak var searchByTextView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchByTextView.layer.cornerRadius = 3.0
        searchByTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchByTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
        view.translatesAutoresizingMaskIntoConstraints = false

        toggleHeightContraintsForSearchMode()
    }

    func toggleHeightContraintsForSearchMode() {
        if searchMode == .byAddress {
            viewHeightConstraintForStops.isActive = false
            viewHeightConstraintForAddress.isActive = true

        } else {
            viewHeightConstraintForAddress.isActive = false
            viewHeightConstraintForStops.isActive = true
        }

        searchView.setNeedsLayout()

        delegate?.animatedLayoutNeeded(block: {
            self.searchView.layoutIfNeeded()
        })
    }

    @IBAction func didToggleSegmentedControl(_ sender: Any) {
        let control = sender as! UISegmentedControl
        if let searchMode = SearchMode(rawValue: control.selectedSegmentIndex) {
            self.searchMode = searchMode
        }
    }

    @IBAction func didTapDismiss(_: Any) {
    }
}

// get rid fo the bottom constraint on this vidw
// when the user taps on the segmented control, its size should grow in a fast animation
