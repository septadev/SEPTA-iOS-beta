//
//  SearchModalHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/25/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule

class SearchModalHeaderViewController: UIViewController {
    weak var delegate: SearchModalHeaderDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            // textField.delegate = delegate.delegateForTextField()
        }
    }

    @IBOutlet weak var viewHeightConstraintForAddress: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraintForStops: NSLayoutConstraint!

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = textFieldDelegate
            textField.placeholder = transitMode.placeHolderText()
        }
    }

    var searchMode: SearchMode = .directLookup {
        didSet {
            toggleHeightContraintsForSearchMode()
        }
    }

    let transitMode: TransitMode! = store.state.scheduleState.scheduleRequest?.transitMode

    var textFieldDelegate: UITextFieldDelegate!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var selectNearbyLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var dismissIcon: UIView!
    @IBOutlet weak var searchByTextView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchByTextView.layer.cornerRadius = 3.0
        searchByTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchByTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
        view.translatesAutoresizingMaskIntoConstraints = false
        selectNearbyLabel.text = transitMode.addressSearchPrompt()
        selectNearbyLabel.isHidden = true
    }

    func toggleHeightContraintsForSearchMode() {
        if searchMode == .byAddress {
            viewHeightConstraintForStops.isActive = false
            viewHeightConstraintForAddress.isActive = true
            searchView.setNeedsLayout()
            delegate?.animatedLayoutNeeded(block: {
                self.searchView.layoutIfNeeded()
            }, completion: { self.selectNearbyLabel.isHidden = false })

        } else {
            selectNearbyLabel.isHidden = true
            viewHeightConstraintForAddress.isActive = false
            viewHeightConstraintForStops.isActive = true
            searchView.setNeedsLayout()
            delegate?.animatedLayoutNeeded(block: {
                self.searchView.layoutIfNeeded()
            }, completion: {})
        }
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
