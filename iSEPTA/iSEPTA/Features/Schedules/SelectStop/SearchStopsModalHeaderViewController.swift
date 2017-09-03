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

class SearchStopsModalHeaderViewController: UIViewController, StoreSubscriber, UIGestureRecognizerDelegate {
    typealias StoreSubscriberStateType = ScheduleStopEdit?
    let transitMode: TransitMode! = store.state.scheduleState.scheduleRequest.transitMode

    @IBOutlet weak var viewHeightConstraintForAddress: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraintForStops: NSLayoutConstraint!
    @IBAction func userTappedSearchByStops(_: Any) {

        if searchMode == .directLookupWithAddress {
            store.dispatch(ClearLookupAddresses())
            store.dispatch(StopSearchModeChanged(searchMode: .byAddress))
        }
    }

    @IBOutlet var resetTextBoxGestureRecognizer: UITapGestureRecognizer!

    weak var delegate: SearchModalHeaderDelegate?

    var textFieldDelegate: UITextFieldDelegate!

    func newState(state: StoreSubscriberStateType) {
        guard let state = state else { return }
        searchMode = state.searchMode
        if let selectedAddress = state.selectedAddress {
            textField.text = selectedAddress.street
            textField.resignFirstResponder()
        }

        switch searchMode {
        case .directLookup:
            textField.clearButtonMode = .never
            textField.isEnabled = true
            textField.text = nil
            searchByLocationButton.isHidden = true
            segmentedControl.selectedSegmentIndex = 0
        case .byAddress:
            textField.clearButtonMode = .never
            textField.isEnabled = true
            textField.text = nil
            searchByLocationButton.isHidden = false
            segmentedControl.selectedSegmentIndex = 1
        case .directLookupWithAddress:
            textField.clearButtonMode = .always
            textField.isEnabled = false
            searchByLocationButton.isHidden = true
        default: break
        }
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
    @IBOutlet weak var searchByLocationButton: UIButton!

    func addCornersAndBorders() {
        searchByTextView.layer.cornerRadius = 3.0
        searchByTextView.layer.borderColor = SeptaColor.subSegmentBlue.cgColor
        searchByTextView.layer.borderWidth = 1.0
        dismissIcon.layer.cornerRadius = 3.0
    }

    @IBAction func SearchByLocation(_: Any) {
        store.dispatch(RequestLocation())
        delegate?.updateActivityIndicator(animating: true)
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
                toggleHeightConstraintsForSearchMode()
                updateTextFieldPlaceholderText()
            }
        }
    }

    func toggleHeightConstraintsForSearchMode() {
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
            }.skipRepeats { $0 == $1 }
        }
    }

    override func viewWillDisappear(_: Bool) {
        store.unsubscribe(self)
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRequireFailureOf _: UIGestureRecognizer) -> Bool {
        delegate?.dismissModal()
        return false
    }
}
