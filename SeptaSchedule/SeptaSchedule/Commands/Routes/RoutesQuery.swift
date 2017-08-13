// Septa. 2017

import Foundation

extension TransitMode: SQLQueryProtocol {

    var sqlBindings: [[String]] {
        return [[String]]()
    }

    var fileName: String {
        switch self {
        case .bus: return "busRoute"
        case .rail: return "railRoute"
        case .subway: return "subwayRoute"
        case .trolley: return "trolleyRoute"
        case .nhsl: return "NHSLRoute"
        }
    }
}
