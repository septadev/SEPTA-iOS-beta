import StoreKit
#if !COCOAPODS
    import PromiseKit
#endif

extension SKReceiptRefreshRequest {
    public func promise() -> Promise<SKReceiptRefreshRequest> {
        return ReceiptRefreshObserver(request: self).promise
    }
}

fileprivate class ReceiptRefreshObserver: NSObject, SKRequestDelegate {
    let (promise, fulfill, reject) = Promise<SKReceiptRefreshRequest>.pending()
    let request: SKReceiptRefreshRequest
    var retainCycle: ReceiptRefreshObserver?

    init(request: SKReceiptRefreshRequest) {
        self.request = request
        super.init()
        request.delegate = self
        request.start()
        retainCycle = self
    }

    func requestDidFinish(_: SKRequest) {
        fulfill(request)
        retainCycle = nil
    }

    func request(_: SKRequest, didFailWithError error: Error) {
        reject(error)
        retainCycle = nil
    }
}
