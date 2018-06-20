//
//  ImagesDataGateway.swift
//  JsonDisplay
//
//  Created by Mike Haydan on 20/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import Foundation

typealias ImagesDataCompleion = (Result<(title: String, models: [ImageModel])>) -> ()

protocol ImagesDataGateway {
    func getImageData(completion: @escaping ImagesDataCompleion)
}

final class ImagesDataGatewayImplementation: ImagesDataGateway {
    
    // MARK: - Properties
    
    let apiClient: ApiClient
    
    // MARK: - LifeCycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public
    
    func getImageData(completion: @escaping ImagesDataCompleion) {
        let headers: [String: String] = ["Accept": "application/json"]
        let request = URLRequest.requestWithURL(path: Urls.images, headers: headers)
        apiClient.execute(request: request) { (result: Result<ApiResponse<FullImageApiModel>>) in
            switch result {
            case let .success(response):
                let resultToBeReturned = (title: response.entity.title,
                                          models: response.entity.imageModels.map({ $0.imageModel }))
                completion(.success(resultToBeReturned))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
