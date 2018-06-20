//
//  ImageModel.swift
//  JsonDisplay
//
//  Created by Mike Haydan on 20/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

struct FullImageApiModel: InitializableCodable {
    let title: String
    let imageModels: [ImageApiModel]
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageModels = "rows"
    }
}

struct ImageApiModel: InitializableCodable {
    let title: String?
    let description: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case imageUrl = "imageHref"
    }
    
    var imageModel: ImageModel {
        return ImageModel(title: title ?? "", description: description ?? "", imageUrl: imageUrl ?? "")
    }
}

struct ImageModel {
    let title: String
    let description: String
    let imageUrl: String
}
