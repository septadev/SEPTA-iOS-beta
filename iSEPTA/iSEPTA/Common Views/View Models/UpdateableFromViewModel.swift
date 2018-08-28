// Septa. 2017

import Foundation

@objc protocol UpdateableFromViewModel: AnyObject {
    func viewModelUpdated()

    func updateActivityIndicator(animating: Bool)

    func displayErrorMessage(message: String, shouldDismissAfterDisplay: Bool)
}

extension UpdateableFromViewModel {
}
