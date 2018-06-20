//
//  APIClient.swift
//  Mobstar
//
//  Created by Mike Haydan on 6/29/17.
//  Copyright © 2017 Petterson Apps. All rights reserved.
//

import Foundation

// MARK: - Constants

enum ApiClientConstnats {
    static let errorMessage: String = "errors"
}

// MARK: - Request Methodes

enum APIRequestMethodes: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Protocols

protocol ApiClient {
    func execute<T>(request: URLRequest, completionHandler: @escaping (_ result: Result<ApiResponse<T>>) -> Void)
    func executeWithDataTask<T>(request: URLRequest, completionHandler: @escaping (_ result: Result<ApiResponse<T>>) -> Void) -> URLSessionDataTask?
    func printResponseDetails(httpUrlResponse: HTTPURLResponse)
    func cancelTasks()
}

final class ApiClientImplementation: ApiClient {
    
    // MARK: - Public Properties
    
    class var defaultConfiguration: ApiClientImplementation {
        return ApiClientImplementation(urlSessionConfiguration: .default, completionHandlerQueue: .main)
    }
    
    let urlSession: URLSession
    
    // MARK: - Lifecycle
    
    private init() {
        urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
    }
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    init(urlSessionConfiguration: URLSessionConfiguration, completionHandlerQueue: OperationQueue) {
        urlSession = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: completionHandlerQueue)
    }
    
    // MARK: - ApiClient
    
    func executeWithDataTask<T>(request: URLRequest, completionHandler: @escaping (_ result: Result<ApiResponse<T>>) -> Void) -> URLSessionDataTask? {
        let dataTask = urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            self?.handleResponse(data: data, response: response, error: error, completionHandler: completionHandler)
        }
        dataTask.resume()
        
        return dataTask
    }
    
    func execute<T>(request: URLRequest, completionHandler: @escaping (Result<ApiResponse<T>>) -> ()) {
        _ = executeWithDataTask(request: request, completionHandler: completionHandler)
    }
    
    func cancelTasks() {
        urlSession.getAllTasks { (tasks) in
            tasks.forEach({ $0.cancel() })
        }
    }
    
    // MARK: - Private
    
    func printResponseDetails(httpUrlResponse: HTTPURLResponse) {
        if let urlString = httpUrlResponse.url?.absoluteString {
            let details: String = "| StatusCode: \(httpUrlResponse.statusCode) | Path: \(urlString) |"
            let line: String = String(repeating: "-", count: details.count)
            print(line)
            print(details)
            print(line)
        }
    }
    
    private func handleResponse<T>(data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (_ result: Result<ApiResponse<T>>) -> Void) {
        if let error = error {
            completionHandler(.failure(error))
            return
        }
        
        guard let httpUrlResponse = response as? HTTPURLResponse else {
            completionHandler(.failure(NetworkRequestError(error: error)))
            return
        }
        
        self.printResponseDetails(httpUrlResponse: httpUrlResponse)
        let successRange = 200...299
        if successRange.contains(httpUrlResponse.statusCode) {
            do {
                let response = try ApiResponse<T>(data: data, httpUrlResponse: httpUrlResponse)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        } else {
            let apiError: HTTPError = HTTPError(statusCode: HTTPErrorCodes(statusCode: httpUrlResponse.statusCode), data: data)
            completionHandler(.failure(apiError))
        }
    }
 }
