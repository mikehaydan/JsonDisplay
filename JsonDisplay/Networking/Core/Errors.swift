//
//  Errors.swift
//  MobStar
//
//  Created by Mike Haydan on 12/04/2018.
//  Copyright © 2018 Petterson Apps. All rights reserved.
//

import Foundation

// MARK: Error: Can't Reach the API
struct NetworkRequestError: LocalizedError {
    let error: Error?
    
    var errorDescription: String? {
        return error?.localizedDescription
    }
}

// MARK: ErrorCode: 4xx
struct ServerResponseApiError: LocalizedError {
    
    private enum Keys {
        static let error: String = "errors"
    }
    
    let data: Data
    let httpUrlResponse: HTTPURLResponse
    let error: Error?
    
    init?(data: Data?, httpUrlResponse: HTTPURLResponse) {
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let errorMessage = json?[Keys.error] as? [String] {
            self.data = data
            self.httpUrlResponse = httpUrlResponse
            let localizedMessages = errorMessage.map({ $0 })
            let message = localizedMessages.joined(separator: "\n")
            self.error = NSError.clientErrorwWith(code: httpUrlResponse.statusCode, errorMessage: message)
        } else {
            return nil
        }
    }
    
    var errorDescription: String? {
        return error?.localizedDescription
    }
}

// MARK: Error
struct ApiParseError: LocalizedError {
    static let code: Int = 999
    let error: Error
    let httpUrlResponse: HTTPURLResponse
    let data: Data?
    
    var errorDescription: String? {
        return error.localizedDescription
    }
}

// MARK: - Custom Errors

extension NSError {
    
    class var parseError: NSError {
        return NSError(domain: "com.misha.ImageSearch", code: 999, userInfo: [NSLocalizedDescriptionKey: "Error parsing"])
    }
    
    class var imageNotExistError: NSError {
        return clientErrorwWith(code: 998, errorMessage: "Image not exist")
    }
    
    static func clientErrorwWith(code: Int, errorMessage: String) -> NSError {
        return NSError(domain: "com.misha.ImageSearch", code: code, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }
}
