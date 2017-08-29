//
//  SimpleRestClient.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation
import PromiseKit
import Alamofire
import ObjectMapper

class SimpleRestClient: NSObject {

    private var url: String
    private var apiKey: String?
    private var headers: HTTPHeaders?

    private init(url: String, apiKey: String?) {

        self.url = url
        HTTPRouter.baseURLString = url

        if apiKey != nil {
            self.apiKey = apiKey
            headers = [
                "x-api-key": apiKey!,
                "Accept": "application/json",
            ]
        }
    }

    public static func defaultClient(url: String, apiKey: String?) -> SimpleRestClient {
        return SimpleRestClient(url: url, apiKey: apiKey)
    }

    // HTTP operations
    public func get<T: Mappable>(route: HTTPRouter, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return httpRequest(method: .get, route: route, parameters: parameters)
    }

    public func post<T: Mappable>(route: HTTPRouter, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return httpRequest(method: .post, route: route, parameters: parameters)
    }

    public func put<T: Mappable>(route: HTTPRouter, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return httpRequest(method: .put, route: route, parameters: parameters)
    }

    public func delete<T: Mappable>(route: HTTPRouter, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return httpRequest(method: .delete, route: route, parameters: parameters)
    }

    private func httpRequest<T: Mappable>(method: HTTPMethod, route: HTTPRouter, parameters: [String: AnyObject]? = nil) -> Promise<T?> {

        return Promise<T?> { (fulfill, reject) -> Void in

            func parsingError(erroString _: String) -> NSError {
                return NSError(domain: "org.septa.SimpleRestClient", code: -100, userInfo: nil)
            }

            request(route.URLString, method: method, parameters: parameters, headers: headers).responseJSON { (response) -> Void in

                // debugPrint(response.result.value ?? "Warning: empty response")   // dump the response

                if let error = response.result.error {
                    reject(error) // network error
                } else {

                    if let apiResponse = Mapper<T>().map(JSONObject: response.result.value) {
                        let status = apiResponse as? RestResponse

                        if status != nil && status!.success {
                            fulfill(apiResponse)
                        } else {
                            if let logicalerror = status?.error {
                                reject(ErrorResult(errorFromAPI: logicalerror))
                            } else {
                                reject(ErrorResult(errorFromAPI: nil))
                            }
                        }
                    } else {
                        let err = NSError(domain: "org.septa.SimpleRestClient", code: -101, userInfo: nil)
                        reject(err)
                    }
                }
            }
        }
    }
}
