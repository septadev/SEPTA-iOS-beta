//
//  EditFavoriteViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/16/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class EditFavoriteViewController: UIViewController, UITextFieldDelegate, IdentifiableController {
    let viewController: ViewController = .editFavoriteViewController

    var favoriteToEdit: Favorite?

    override func awakeFromNib() {
        favoriteToEdit = store.state.favoritesState.favoriteToEdit
    }

    var favoriteHasBeenSaved: Bool {
        guard let favoriteToEdit = favoriteToEdit else { return false }
        return store.state.favoritesState.favorites.contains(favoriteToEdit)
    }

    @IBOutlet weak var deleteFavoriteButton: DeleteFavoriteButton! {
        didSet {
            deleteFavoriteButton.isEnabled = favoriteHasBeenSaved
        }
    }

    @IBOutlet weak var existingFavoriteTitleLabel: UILabel!
    @IBOutlet weak var textField: UITextField! {
        didSet { textField.delegate = self }
    }

    @IBOutlet weak var saveButton: SaveFavoriteButton!

    @IBAction func closeButtonTapped(_: Any) {
        view.resignFirstResponder()
        let action = CancelFavoriteEdit()
        store.dispatch(action)
    }

    @IBAction func deleteFavoriteButtonTapped(_: Any) {
        guard let favoriteToEdit = favoriteToEdit else { return }
        view.resignFirstResponder()
        requestPermissionToRemoveFavorite(favorite: favoriteToEdit)
    }

    @IBAction func saveButtonTapped(_: Any) {
        guard var favoriteToEdit = favoriteToEdit, let text = textField.text else { return }
        view.resignFirstResponder()
        favoriteToEdit.favoriteName = text
        let action = SaveFavorite(favorite: favoriteToEdit)
        store.dispatch(action)
    }

    var filterString = "" {
        didSet {
            saveButton.isEnabled = filterString.count > 0
        }
    }

    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        guard let swiftRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: swiftRange, with: replacementString)
        return true
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        filterString = ""
        return true
    }

    override func viewDidLoad() {
        guard let favoriteName = favoriteToEdit?.favoriteName else { return }
        view.backgroundColor = SeptaColor.editFavoriteBlue
        textField.text = favoriteName
        filterString = favoriteName
        existingFavoriteTitleLabel.text = favoriteName
        textField.selectAll(self)
    }

    override func viewDidAppear(_: Bool) {

        textField.becomeFirstResponder()
    }

    func requestPermissionToRemoveFavorite(favorite: Favorite) {

        UIAlert.presentDestructiveYesNoAlertFrom(viewController: self, withTitle: "Remove a Favorite?", message: "Would you like to remove this trip as a favorite?") {

            if store.state.targetForScheduleActions() == .favorites {
                let action = PopViewController(viewController: .nextToArriveDetailController, description: "Can't show more when there are no favorites")
                store.dispatch(action)
            }
            let action = RemoveFavorite(favorite: favorite)
            store.dispatch(action)
        }
    }
}
