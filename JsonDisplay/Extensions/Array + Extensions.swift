//
//  Array + Extensions.swift
//  MobStar
//
//  Created by Mike Haydan on 18/04/2018.
//  Copyright © 2018 Petterson Apps. All rights reserved.
//

import Foundation

extension Array: InitializableWithData {
    init(data: Data?) throws {
        guard let data = data else {
            throw NSError.parseError
        }
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data)
            guard let jsonArray = jsonObject as? [[String: Any]] else {
                throw NSError.parseError
            }
            
            guard let element = Element.self as? InitializableWithJson.Type else {
                throw NSError.parseError
            }
            self = try jsonArray.map({ return try element.init(json: $0) as! Element })
        } catch {
            throw NSError.parseError
        }
    }
}

extension Array where Element: Comparable {
    
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
    
}
