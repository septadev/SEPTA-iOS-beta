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
import ReSwift

class SearchModalHeaderViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleStopEdit?
    let transitMode: TransitMode! = store.state.scheduleState.scheduleRequest?.transitMode

    @IBOutlet weak var viewHeightConstraintForAddress: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraintForStops: NSLayoutConstraint!

    weak var delegate: SearchModalHeaderDelegate?

    var textFieldDelegate: UITextFieldDelegate!

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        searchMode = state.searchMode
        toggleHeightContraintsForSearchMode()
    }

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var selectNearbyLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var dismissIcon: UIView!
    @IBOutlet weak var searchByTextView: UIView!

    func addCornersAndBorders() {
        searchByTextView.layer.cornerRadius = 3.0
        searchByTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchByTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
    }

    @IBAction func didToggleSegmentedControl(_ sender: Any) {
        guard let segmentedControl = sender as? UISegmentedControl else { return }
        searchMode = mapSelectedSegmentToSearchMode(index: segmentedControl.selectedSegmentIndex)
    }

    func mapSelectedSegmentToSearchMode(index: Int) -> StopEditSearchMode {
        return index == 0 ? .directLookup : .byAddress
    }

    // MARK: - Search Mode
    var searchMode: StopEditSearchMode! {
        didSet {
            if oldValue != searchMode {
                store.dispatch(StopSearchModeChanged(searchMode: searchMode))
                toggleHeightContraintsForSearchMode()
                updateTextFieldPlaceholderText()
            }
        }
    }

    func toggleHeightContraintsForSearchMode() {
        switch searchMode {
        case .directLookup, .byAddress:
            viewHeightConstraintForAddress.isActive = false
            viewHeightConstraintForStops.isActive = true

        default:
            viewHeightConstraintForStops.isActive = false
            viewHeightConstraintForAddress.isActive = true
        }
        searchView.setNeedsLayout()

        delegate?.animatedLayoutNeeded(block: {
            self.searchView.layoutIfNeeded()
        }, completion: {
            self.selectNearbyLabel.isHidden = self.searchMode != .directLookupWithAddress

        })
    }

    func updateTextFieldPlaceholderText() {
        textField.placeholder = searchMode.textFieldPlaceHolderText(transitMode: transitMode)
    }

    // MARK: - Initial Layout
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        addCornersAndBorders()

        view.translatesAutoresizingMaskIntoConstraints = false
        selectNearbyLabel.text = transitMode.addressSearchPrompt()
        selectNearbyLabel.isHidden = true
    }

    // MARK: - View Life Cycle
    @IBAction func didTapDismiss(_: Any) {
        delegate?.dismissModal()
    }

    func subscribe() {

        store.subscribe(self) {
            $0.select {
                $0.scheduleState.scheduleStopEdit
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        store.unsubscribe(self)
    }
}
