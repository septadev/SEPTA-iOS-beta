

import Foundation
import UIKit

protocol SingleStringDisplayable {
    func setTextColor(_ color: UIColor)
    func setLabelText(_ text: String?)
    func setAccessoryType(_ accessoryType: UITableViewCellAccessoryType)
    func setOpacity(_ opacity: Float)
    func setShouldFill(_ shouldFill: Bool)
}
