//
//  ImageModel.swift
//  JsonDisplay
//
//  Created by Mike Haydan on 20/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import Foundation

struct FullImageApiModel: InitializableCodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageModels = "rows"
    }
    
    // MARK: - Properties
    
    let title: String
    let imageModels: [ImageApiModel]
    
    // MARK: - LifeCycle
    
    init(data: Data?) throws {
        if let data = data, let replacedData = String(data: data, encoding: .ascii)?.replacingOccurrences(of: "\\", with: "\\\\").data(using: .utf8) {
            let jsonDecoder = JSONDecoder()
            do {
                let model = try jsonDecoder.decode(FullImageApiModel.self, from: replacedData)
                self = model
            } catch {
                throw NSError.parseError
            }
        } else {
            throw NSError.parseError
        }
    }
}

struct ImageApiModel: InitializableCodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case imageUrl = "imageHref"
    }
    
    // MARK: - Properties
    
    let title: String?
    let description: String?
    let imageUrl: String?
    
    var imageModel: ImageModel {
        return ImageModel(title: title ?? "", description: description ?? "", imageUrl: imageUrl ?? "")
    }
}

struct ImageModel {
    let title: String
    let description: String
    let imageUrl: String
}
