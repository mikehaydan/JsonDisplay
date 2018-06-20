//
//  URLRequest+Extensions.swift
//  URLSession
//
//  Created by Mike Haydan on 3/15/18.
//  Copyright © 2018 Petterson Apps. All rights reserved.
//

import Foundation

extension URLRequest {
    
    static func requestWithURL(path: String, pathParameter: String = "", method: APIRequestMethodes = .get, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any?]? = nil, headers: [String: String?]? = nil) -> URLRequest {
        
        var actualURL: URL = URL(string: path, relativeTo: Urls.baseUrl)!
        
        if !pathParameter.isEmpty {
            actualURL.appendPathComponent(pathParameter)
        }
        
        if let queryParameters = queryParameters {
            var components = URLComponents(url: actualURL, resolvingAgainstBaseURL: true)!
            var queryItems: [URLQueryItem] = []
            queryParameters.forEach({ (key, value) in
                if let arrayValue = value as? [Any] {
                    let keyArray =  "\(key)[]"
                    arrayValue.forEach({
                        queryItems.append(URLQueryItem(name: keyArray, value: "\($0)"))
                    })
                } else {
                    queryItems.append(URLQueryItem(name: "\(key)", value: "\(value)"))
                }
            })
            components.queryItems = queryItems
            actualURL = components.url!
        }
        
        var request: URLRequest = URLRequest(url: actualURL)
        request.httpMethod = method.rawValue
        
        if let bodyParameters = bodyParameters {
            let parameters: [String: Any?] = bodyParameters.filter({ $0.value != nil })
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = parameters.toJsonData()
        }
        
        if let headers = headers {
            for (field, value) in headers {
                if let value = value {
                    request.addValue(value, forHTTPHeaderField: field)
                }
            }
        }
        
        printReuquestDetails(httpMethod: method, urlString: actualURL.absoluteString, parameters: bodyParameters)
        
        return request
    }
    
    private static func printReuquestDetails(httpMethod: APIRequestMethodes, urlString: String, parameters: [String: Any?]?) {
        let details: String = "| Method: \(httpMethod.rawValue) | Path: \(urlString) |"
        let line: String = String(repeating: "-", count: details.count)
        print("\n\(line)")
        print(details)
        print(line)
        guard let parameters = parameters else {
            print("No Parameters")
            return
        }
        parameters.printJson()
    }
}
