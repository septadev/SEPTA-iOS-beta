
public struct TripStopId {
    public let start: Int
    public let end: Int

    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}

extension TripStopId: Equatable {}
public func == (lhs: TripStopId, rhs: TripStopId) -> Bool {
    var areEqual = true

    if lhs.start == rhs.start {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.end == rhs.end {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    return areEqual
}
