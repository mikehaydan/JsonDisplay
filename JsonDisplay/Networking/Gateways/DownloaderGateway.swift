//
//  DownloaderGateway.swift
//  MobStar
//
//  Created by Mike Haydan on 20/04/2018.
//  Copyright © 2018 Petterson Apps. All rights reserved.
//

import UIKit

typealias ImageDownloadCompletion = (Result<UIImage>) -> ()

protocol DownloaderGateway: class {
    func downloadImageBy(urlString: String, dataTaskHandler: ((URLSessionDataTask?) -> ())?, completion: @escaping ImageDownloadCompletion)
    func downloadImageBy(urlString: String, completion: @escaping ImageDownloadCompletion)
    func cancelDownload()
    func imageNameFrom(url: String) -> String?
}

extension DownloaderGateway {
    func imageNameFrom(url: String) -> String? {
        return nil
    }
}

// MARK: - DownloadedImage

private struct DownloadedImage: InitializableWithData {
    
    let image: UIImage
    
    init(data: Data?) throws {
        if let data = data, let image = UIImage(data: data) {
            self.image = image
        } else {
            throw NSError.parseError
        }
    }
}

// MARK: - DownloaderGatewayImplementation

class DownloaderGatewayImplementation: DownloaderGateway {
    
    // MARK: - Properties
    
    let apiClient: ApiClient
    
    // MARK: - LifeCycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public
    
    func downloadImageBy(urlString: String, dataTaskHandler: ((URLSessionDataTask?) -> ())? = nil, completion: @escaping ImageDownloadCompletion) {
        let url: URL = URL(string: urlString)!
        let request = URLRequest(url: url)
        let task = apiClient.executeWithDataTask(request: request) { (result: Result<ApiResponse<DownloadedImage>>) in
            switch result {
            case let .success(response):
                let image = response.entity.image
                completion(.success(image))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        dataTaskHandler?(task)
    }
    
    func downloadImageBy(urlString: String, completion: @escaping ImageDownloadCompletion) {
        self.downloadImageBy(urlString: urlString, dataTaskHandler: nil, completion: completion)
    }
    
    func cancelDownload() {
        apiClient.cancelTasks()
    }
    
    func imageNameFrom(url: String) -> String? {
        return URL(string: url)?.absoluteString.replacingOccurrences(of: "/", with: "_")
    }
}
