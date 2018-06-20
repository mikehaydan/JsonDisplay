//
//  CacheGateway.swift
//  MobStar
//
//  Created by Mike Haydan on 20/04/2018.
//  Copyright © 2018 Petterson Apps. All rights reserved.
//

import UIKit

private struct CacheGatewayConstants {
    static let imageFolder: String = "/images"
}

protocol CacheGateway: DownloaderGateway {
    func cancelDownload()
}

final class CacheGatewayImplementation: CacheGateway {
    
    // MARK: - Properties
    
    let downloader: DownloaderGateway
    let queue: DispatchQueue = DispatchQueue(label: "Downloader", qos: .default)
    
    private lazy var imagePath: String = {
        let documentPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        let path = documentPath + CacheGatewayConstants.imageFolder
        return path
    }()
    // MARK: - LifeCycle
    
    init(downloader: DownloaderGateway) {
        self.downloader = downloader
        self.prepapreFolders()
    }
    
    // MARK: - Private
    
    // MARK: - Files

    private func prepapreFolders() {
        if !directoryExistsAtPath(imagePath) {
            do {
                try FileManager.default.createDirectory(atPath: imagePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    // MARK: - Images
    
    private func save(image: UIImage, name: String) {
        if let data = UIImageJPEGRepresentation(image, 0.9) {
            do {
                let path = imagePath + "/\(name)"
                let url: URL = URL(fileURLWithPath: path)
                try data.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCacheImageWtih(name: String) -> UIImage? {
        let resultImage: UIImage?
        let path = self.imagePath + "/\(name)"
        do {
            let url: URL = URL(fileURLWithPath: path)
            let imageData = try Data(contentsOf: url)
            if let fileImage = UIImage(data: imageData) {
                resultImage = fileImage
            } else {
                resultImage = nil
            }
        } catch {
            resultImage = nil
        }
        return resultImage
    }
    
    private func isImageExistWith(name: String) -> Bool {
        let imagePath = self.imagePath + "/\(name)"
        return FileManager.default.fileExists(atPath: imagePath)
    }
    
    // MARK: - Public
    
    func downloadImageBy(urlString: String, dataTaskHandler: ((URLSessionDataTask?) -> ())? = nil, completion: @escaping ImageDownloadCompletion) {
        if let imageName = downloader.imageNameFrom(url: urlString) {
            queue.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                if let image = strongSelf.getCacheImageWtih(name: imageName) {
                        dataTaskHandler?(nil)
                        completion(.success(image))
                } else {
                    strongSelf.downloader.downloadImageBy(urlString: urlString, dataTaskHandler: dataTaskHandler, completion: { [weak self] (result) in
                        guard let strongSelf = self else {
                            return
                        }
                        switch result {
                        case let .success(response):
                            strongSelf.save(image: response, name: imageName)
                            completion(.success(response))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    })
                }
            }
        } else {
            completion(.failure(NSError.imageNotExistError))
        }
    }
    
    func downloadImageBy(urlString: String, completion: @escaping ImageDownloadCompletion) {
        self.downloadImageBy(urlString: urlString, dataTaskHandler: nil, completion: completion)
    }
    
    func cancelDownload() {
        downloader.cancelDownload()
    }
}
