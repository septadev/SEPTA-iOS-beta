//
//  EditFavoriteViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/16/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class EditFavoriteViewController: UIViewController, UITextFieldDelegate {
    var favoriteToEdit: Favorite?

    override func awakeFromNib() {
        favoriteToEdit = store.state.favoritesState.favoriteToEdit
    }

    @IBOutlet weak var textField: UITextField!

    @IBAction func closeButtonTapped(_: Any) {
        view.resignFirstResponder()
        let action = CancelFavoriteEdit()
        store.dispatch(action)
    }

    @IBAction func deleteFavoriteButtonTapped(_: Any) {
        guard let favoriteToEdit = favoriteToEdit else { return }

        requestPermissionToRemoveFavorite(favorite: favoriteToEdit)
    }

    @IBAction func saveButtonTapped(_: Any) {
        guard var favoriteToEdit = favoriteToEdit, let text = textField.text else { return }
        view.resignFirstResponder()
        favoriteToEdit.favoriteName = text
        let action = SaveFavorite(favorite: favoriteToEdit)
        store.dispatch(action)
    }

    var filterString = ""
    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        guard let swiftRange = Range(range, in: filterString) else { return false }
        filterString = filterString.replacingCharacters(in: swiftRange, with: replacementString)
        return true
    }

    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.editFavoriteBlue
        textField.text = favoriteToEdit?.favoriteName
        textField.selectAll(self)
    }

    override func viewDidAppear(_: Bool) {
        textField.selectAll(self)
        textField.becomeFirstResponder()
    }

    func requestPermissionToRemoveFavorite(favorite: Favorite) {
        guard let presentingViewController = presentingViewController else { return }
        UIAlert.presentDestructiveYesNoAlertFrom(viewController: presentingViewController, withTitle: "Remove a Favorite?", message: "Would you like to remove this trip as a favorite?") { [weak self] in
            self?.view.resignFirstResponder()
            let action = RemoveFavorite(favorite: favorite)
            store.dispatch(action)
        }
    }
}
