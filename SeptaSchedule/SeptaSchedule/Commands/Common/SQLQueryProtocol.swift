// Septa. 2017

import Foundation

protocol SQLQueryProtocol {
    var sqlBindings: [[String]] { get }

    var fileName: String { get }
}
