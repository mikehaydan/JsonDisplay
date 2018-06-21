//
//  DownloadImageView.swift
//  ImageSearch
//
//  Created by Mike Haydan on 09/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import UIKit

final class DownloaderImageView: UIImageView {

    // MARK: - Properties
    
    private var downloadTask: URLSessionDataTask?
    private weak var downloader: CacheGateway!
    
    // MARK: - LifeCycle

    deinit {
        downloadTask?.cancel()
    }
    
    // MARK: - Public
    
    func cancelDownload() {
        downloadTask?.cancel()
    }
    
    func downloadImagefrom(url: String, downloader: CacheGateway, placeholder: UIImage? = nil, complation: ((Result<UIImage>) -> ())? = nil) {
        image = placeholder
        self.downloader = downloader
        downloader.downloadImageBy(urlString: url, dataTaskHandler: { [weak self] (dataTask) in
            self?.downloadTask = dataTask
        }, completion: { [weak self] (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case let .success(response):
                    strongSelf.image = response
                case let .failure(error):
                    let nsError = error as NSError
                    if nsError.code != URLError.cancelled.rawValue {
                        strongSelf.image = placeholder
                    } 
                    print(error.localizedDescription)
                }
                complation?(result)
            }
        })
    }
}
