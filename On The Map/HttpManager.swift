//
//  HttpManager.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import Foundation

class HttpManager {
    
    static let shared = HttpManager()
    
    private let session = URLSession.shared
    
    func taskForGETRequest(_ method: String, parameters: [String:AnyObject]?, api: API, completionHandlerForGET: @escaping (_ result: AnyObject? , _ error: NSError? ) -> Void) -> URLSessionTask {
        
        var request = NSMutableURLRequest(url: urlWithParameters(parameters, withPathExtension: method, using: api))
        
        
        let task = session.dataTask(with: addMethodAndHeaders(request, method: HTTPMethods.GET, api: api)) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                completionHandlerForGET(nil, error! as NSError)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if api == API.udacity {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPOSTRequest(_ method: String, parameters: [String:AnyObject]?, api: API, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError? ) -> Void) -> URLSessionTask {
        
        var request = NSMutableURLRequest(url: urlWithParameters(parameters, withPathExtension: method, using: api))
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: addMethodAndHeaders(request, method: HTTPMethods.POST, api: api)) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                completionHandlerForPOST(nil, error! as NSError)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("\((response as? HTTPURLResponse)!.statusCode)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if api == API.udacity {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            }
            
            
        }
        
        task.resume()
        
        return task
    }
    
    func taskForDELETRequest(_ method: String, api: API, completionHandlerForDELETE: @escaping (_ success: Bool) -> Void) -> URLSessionTask {
        let request = NSMutableURLRequest(url: urlWithParameters(nil, withPathExtension: method, using: api))
        request.httpMethod = HTTPMethods.DELETE
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: addMethodAndHeaders(request, method: HTTPMethods.DELETE, api: api)) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandlerForDELETE(false)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForDELETE(false)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandlerForDELETE(false)
                return
            }
            
            completionHandlerForDELETE(true)
        
        }
        
        task.resume()
        
        return task
        
    }
    
    private func urlWithParameters(_ parameters: [String:AnyObject]?, withPathExtension: String? = nil, using: API) -> URL {
        
        var components = URLComponents()
        components.scheme = Scheme.ApiScheme
        components.host = using == API.parse ? ParseConstants.ApiHost : UdacityConstants.ApiHost
        components.path = using == API.parse ? ParseConstants.ApiPath + (withPathExtension ?? "") : UdacityConstants.ApiPath + (withPathExtension ?? "")
        
        guard (parameters != nil) else {
            return components.url!
        }
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters! {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func addMethodAndHeaders(_ request: NSMutableURLRequest, method: String, api: API) -> URLRequest {
        request.httpMethod = method
        
        if api == API.parse {
            request.addValue(ParseConstants.ParseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(ParseConstants.ParseRestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        if method == HTTPMethods.POST {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request as URLRequest
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            completionHandlerForConvertData(parsedResult, nil)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
    }
    
    func buildAuthenticationHttpBody(username: String, password: String) -> String {
        
        var httpBody = HttpBody.AuthorizationBody
        httpBody = httpBody.replacingOccurrences(of: "<user-name>", with: username)
        httpBody = httpBody.replacingOccurrences(of: "<password>", with: password)
        
        return httpBody
    }
    
    func postNewLocation(_ jsonBody: String, completionHandler: @escaping (_ success: Bool) -> Void ) {
        let _ = HttpManager.shared.taskForPOSTRequest(Methods.ParseStudentLocation, parameters: nil, api: .parse, jsonBody: jsonBody) { (results,error) in
            
            if error == nil {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
}
