//
//  APIErrorResult.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation

public class ErrorResult: NSError {
    var error: Error?

    init(errorFromAPI: Error?) {

        let userInfo: [String: AnyObject] = {
            if let err = errorFromAPI {
                return ["apiError": err]
            } else {
                return ["apiError": "Generic Error" as AnyObject]
            }
        }()

        super.init(domain: "org.septa.ErrorResult", code: -101, userInfo: userInfo)
        error = errorFromAPI
    }

    func errorMessage() -> String {
        guard let apierr = self.error, let errName = apierr.errorName else { return "Generic error" }
        return errName
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
