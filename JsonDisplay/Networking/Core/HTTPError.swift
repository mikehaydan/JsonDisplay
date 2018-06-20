//
//  HTTPError.swift
//  Mobstar
//
//  Created by Mike Haydan on 7/13/17.
//  Copyright © 2017 Petterson Apps. All rights reserved.
//

import Foundation

final class HTTPError: LocalizedError {
    
    private struct Keys {
        static let error: String = "errors"
    }
    
    // MARK: - Properties
    let statusCode: HTTPErrorCodes
    
    public var errorDescription: String? {
        return errorMessage == nil ? "\(statusCode.code): \(HTTPURLResponse.localizedString(forStatusCode: statusCode.code))" : errorMessage
    }
    
    let errorMessage: String?
    
    // MARK: - Lifecycle
    init(statusCode: HTTPErrorCodes, data: Data?) {
        self.statusCode = statusCode
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let errorMessage = json?[Keys.error] as? [String] {
            let localizedMessages = errorMessage.map({ $0 })
            self.errorMessage = localizedMessages.joined(separator: "\n")
        } else {
            self.errorMessage = nil
        }
    }
}

enum HTTPErrorCodes: Int {
    
    case `continue` = 100,
    switchingProtocols = 101
    
    case success = 200,
    created = 201,
    accepted = 202,
    nonAuthoritativeInformation = 203,
    noContent = 204,
    resetContent = 205,
    partialContent = 206
    
    case multipleChoices = 300,
    movedPermanently = 301,
    found = 302,
    seeOther = 303,
    notModified = 304,
    useProxy = 305,
    unused = 306,
    temporaryRedirect = 307
    
    case badRequest = 400,
    unauthorized = 401,
    paymentRequired = 402,
    forbidden = 403,
    notFound = 404,
    methodNotAllowed = 405,
    notAcceptable = 406,
    proxyAuthenticationRequired = 407,
    requestTimeout = 408,
    conflict = 409,
    gone = 410,
    lengthRequired = 411,
    preconditionFailed = 412,
    requestEntityTooLarge = 413,
    requestUriTooLong = 414,
    unsupportedMediaType = 415,
    requestedRangeNotSatisfiable = 416,
    expectationFailed = 417
    
    case internalServerError = 500,
    notImplemented = 501,
    badGateway = 502,
    serviceUnavailable = 503,
    gatewayTimeout = 504,
    httpVersionNotSupported = 505
    
    case invalidUrl = -1001
    
    case unknownStatus = 0
    
    var code: Int { return self.rawValue }
    
    // MARK: - LifeCycle
    
    init(statusCode: Int) {
        self = HTTPErrorCodes(rawValue: statusCode) ?? .unknownStatus
    }
}
