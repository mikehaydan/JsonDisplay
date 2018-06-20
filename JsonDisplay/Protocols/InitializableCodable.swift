//
//  InitializableCodable.swift
//  MobStar
//
//  Created by Mike Haydan on 18/04/2018.
//  Copyright © 2018 Petterson Apps. All rights reserved.
//

import Foundation

protocol InitializableCodable: InitializableWithData, InitializableWithJson, Codable {
    
}

extension InitializableCodable {
    
    init(data: Data?) throws {
        if let data = data {
            let jsonDecoder = JSONDecoder()
            do {
                let model = try jsonDecoder.decode(Self.self, from: data)
                self = model
            } catch {
                throw NSError.parseError
            }
        } else {
            throw NSError.parseError
        }
    }
    
    init(json: [String: Any]) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            try self.init(data: jsonData)
        } catch {
            throw NSError.parseError
        }
    }
    
}
