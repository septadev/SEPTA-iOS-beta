//
//  TestGenericAlertDetailProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 1/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

private typealias AlertDetailsCompletion = (([AlertDetails_Alert]) -> Void)
private typealias NetworkCompletion = ((Data?, URLResponse?, Swift.Error?) -> Void)

class TestGenericAlertDetailProvider: StateProvider {
    static let sharedInstance = TestGenericAlertDetailProvider()

    fileprivate let host = SeptaNetwork.sharedInstance.genericAlertTestHost
    fileprivate let path = SeptaNetwork.sharedInstance.genericAlertTestPath
    fileprivate let genericAlertName = SeptaNetwork.sharedInstance.genericAlertName
    fileprivate let appAlertName = SeptaNetwork.sharedInstance.appAlertName
    fileprivate var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(timeInterval: 10 * 60, target: self, selector: #selector(timerFired(timer:)), userInfo: nil, repeats: true)
        getGenericAlert()
        getAppAlerts()
    }

    @objc private func timerFired(timer _: Timer) {
        getGenericAlert()
        getAppAlerts()
    }

    fileprivate func getGenericAlert() {
        sendRequest(alertName: genericAlertName, completionHandler: handleGenericAlertResponse)
    }

    fileprivate func getAppAlerts() {
        sendRequest(alertName: appAlertName, completionHandler: handleAppAlertResponse)
    }

    fileprivate func sendRequest(alertName: String, completionHandler: @escaping NetworkCompletion) {
        guard let request = buildRequest(alertName: alertName) else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        session.finishTasksAndInvalidate()
    }

    fileprivate func handleGenericAlertResponse(data: Data?, response _: URLResponse?, error: Swift.Error?) {
        guard let data = data, error == nil else { print("URL Session Task Failed: %@", error!.localizedDescription); return }
        do {
            try mapResponse(data: data, alertDetailsCompletion: updateGenericAlerts)
        } catch {
            print("JSON Deserialization Failed", error.localizedDescription)
        }
    }

    fileprivate func handleAppAlertResponse(data: Data?, response _: URLResponse?, error: Swift.Error?) {
        guard let data = data, error == nil else { print("URL Session Task Failed: %@", error!.localizedDescription); return }
        do {
            try mapResponse(data: data, alertDetailsCompletion: updateAppAlerts)
        } catch {
            print("JSON Deserialization Failed", error.localizedDescription)
        }
    }

    fileprivate func mapResponse(data: Data, alertDetailsCompletion: AlertDetailsCompletion) throws {
        if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]],
            let messages = extractMessages(jsonArray: jsonArray) {

            generateAlertDetails(messages: messages, alertDetailsCompletion: alertDetailsCompletion)
        }
    }

    fileprivate func generateAlertDetails(messages: [String], alertDetailsCompletion: AlertDetailsCompletion) {
        let alertDetails: [AlertDetails_Alert] = messages.map {
            let alertDetails = AlertDetails_Alert()
            alertDetails.message = $0
            return alertDetails
        }
        alertDetailsCompletion(alertDetails)
    }

    fileprivate func updateGenericAlerts(genericAlertDetails: [AlertDetails_Alert]) {
        DispatchQueue.main.async {

            let action = GenericAlertDetailsLoaded(genericAlertDetails: genericAlertDetails)
            store.dispatch(action)
        }
    }

    fileprivate func updateAppAlerts(appAlertDetails: [AlertDetails_Alert]) {
        DispatchQueue.main.async {
            let action = AppAlertDetailsLoaded(appAlertDetails: appAlertDetails)
            store.dispatch(action)
        }
    }

    /// helper classes
    fileprivate func extractMessages(jsonArray: [[String: Any]]) -> [String]? {
        guard let messages = jsonArray
            .map({ $0["current_message"] })
            .flatMap({ $0 })
            .filter({
                guard let string = $0 as? String else { return false }
                return string.count > 0
            }
            ) as? [String] else {
            return nil
        }
        return messages
    }

    fileprivate func buildURL(alertName: String) -> URL? {
        guard var url = URL(string: "\(host)/\(path)") else { return nil }
        url = url.appendingQueryParameters(["req1": alertName])
        return url
    }

    fileprivate func buildRequest(alertName: String) -> URLRequest? {
        guard let url = buildURL(alertName: alertName) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        return request
    }

    deinit {
        timer?.invalidate()
    }
}
