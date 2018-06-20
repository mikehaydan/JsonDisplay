//
//  Dictionary+Extension.swift
//  URLSession
//
//  Created by Mike Haydan on 3/15/18.
//  Copyright © 2018 Petterson Apps. All rights reserved.
//

import Foundation

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

    public func toJsonData() -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            return Data()
        }
    }
}

extension Dictionary where Value: Equatable {
    
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.0
    }
}

extension Dictionary {
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(json)
    }
}
