//
//  APIResponse.swift
//  MVP
//
//  Created by Mike Haydan on 6/29/17.
//  Copyright © 2017 Petterson Apps. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol InitializableWithData {
    init(data: Data?) throws
}

protocol InitializableWithJson {
    init(json: [String: Any]) throws
}

// MARK: - Response Handling

final class ApiResponse<T: InitializableWithData> {
    let entity: T
    let httpUrlResponse: HTTPURLResponse
    let data: Data?
    
    init(data: Data?, httpUrlResponse: HTTPURLResponse) throws {
        do {
            self.entity = try T(data: data)
            self.httpUrlResponse = httpUrlResponse
            self.data = data
            //self.entity.printJson()
        } catch {
            throw ApiParseError(error: error, httpUrlResponse: httpUrlResponse, data: data)
        }
    }
}

final class VoidResponse: InitializableWithData {
    init(data: Data?) throws {
        
    }
}

// MARK: - Result

enum Result<T> {
    case success(T)
    case failure(Error)
    
    public func dematerialize() throws -> T {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}
