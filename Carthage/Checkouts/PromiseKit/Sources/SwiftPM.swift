public enum CatchPolicy {
    case allErrorsExceptCancellation
    case allErrors
}

func PMKUnhandledErrorHandler(_: Error)
{}

import class Dispatch.DispatchQueue

func __PMKDefaultDispatchQueue() -> DispatchQueue {
    return DispatchQueue.main
}

func __PMKSetDefaultDispatchQueue(_: DispatchQueue)
{}
