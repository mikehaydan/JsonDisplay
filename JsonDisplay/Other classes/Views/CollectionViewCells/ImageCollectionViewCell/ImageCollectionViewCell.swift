//
//  ImageCollectionViewCell.swift
//  JsonDisplay
//
//  Created by Mike Haydan on 21/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import UIKit

protocol ImageCollectionViewCellDelegate: class {
    func downloadingFinishedFor(cell: UICollectionViewCell, image: UIImage)
}

final class ImageCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: DownloaderImageView!
    private weak var delegate: ImageCollectionViewCellDelegate?
    
    // MARK: - LifeCycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.cancelDownload()
        imageView.image = nil
        activityIndicatorView.stopAnimating()
    }

    // MARK: - Public

    func configureWith(model: ImageModel, placeholder: UIImage?, downloader: CacheGateway, delegate: ImageCollectionViewCellDelegate?) {
        self.delegate = delegate
        if let image = model.image {
            imageView.image = image
        } else {
            activityIndicatorView.startAnimating()
            getImage(url: model.imageUrl, downloader: downloader, placeholder: placeholder, delegate: delegate)
        }
    }
    
    // MARK: - Private
    
    private func getImage(url: String, downloader: CacheGateway, placeholder: UIImage?, delegate: ImageCollectionViewCellDelegate?) {
        imageView.dwonloadImagefrom(url: url, downloader: downloader, placeholder: placeholder) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case let .success(response):
                strongSelf.delegate?.downloadingFinishedFor(cell: strongSelf, image: response)
            default:
                break
            }
            strongSelf.activityIndicatorView.stopAnimating()
        }
    }

}
