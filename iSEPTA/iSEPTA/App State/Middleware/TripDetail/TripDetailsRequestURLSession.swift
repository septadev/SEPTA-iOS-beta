import Foundation
/*
 {
 "vehicleId" : "237",
 "delayType" : "ACTUAL",
 "notificationType" : "DELAY",
 "message" : "Norristown: Train #237 going to Marcus Hook is operating 15 minutes late. Last at Main St.",
 "routeType" : "RAIL",
 "routeId" : "NOR",
 "google.c.a.e" : "1",
 "gcm.message_id" : "0:1541444889521948%65771b2f65771b2f",
 "aps" : {
 "alert" : {
 "title" : "Train Delay on NOR",
 "body" : "Norristown: Train #237 going to Marcus Hook is operating 15 minutes late. Last at Main St."
 }
 },
 "destinationStopId" : "90205"
 }
 */

class TripDetailsRequestURLSession {
    func sendRequestRealTimeTripsDetails(notification: SeptaDelayNotification) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        guard let baseUrl = Bundle.main.object(forInfoDictionaryKey: "septaBaseUrl") as? String,
            var url = URL(string: "\(baseUrl)/realtimearrivals/details"),
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "septaApiKey") as? String else { return }

        let URLParams = [ "destination": notification.destinationStopId,
                          "id": notification.vehicleId,
        ]
        url = url.appendingQueryParameters(URLParams)
        
        let request = buildRequest(url: url, key: apiKey)

        /* Start a new Task */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let task = session.dataTask(with: request) { data, response, error in
                if error == nil {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                    let resultsData = try! JSONSerialization.jsonObject(with: data!, options: [])
                    print("Results: \(resultsData)")
                } else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription)
                }
            }
            task.resume()
//        session.finishTasksAndInvalidate()
        }
    }

    fileprivate func buildRequest(url: URL, key: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        return request
    }

}

/*
 protocol URLQueryParameterStringConvertible {
 var queryParameters: String {get}
 }

 extension Dictionary : URLQueryParameterStringConvertible {
 /**
  This computed property returns a query parameters string from the given NSDictionary. For
  example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
  string will be @"day=Tuesday&month=January".
  @return The computed parameters string.
  */
 var queryParameters: String {
 var parts: [String] = []
 for (key, value) in self {
 let part = String(format: "%@=%@",
 String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
 String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
 parts.append(part as String)
 }
 return parts.joined(separator: "&")
 }

 }

 extension URL {
 /**
  Creates a new URL by adding the given query parameters.
  @param parametersDictionary The query parameter dictionary to add.
  @return A new URL.
  */
 func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
 let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
 return URL(string: URLString)!
 }
 }*/
