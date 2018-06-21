//
//  DetailsViewController.swift
//  JsonDisplay
//
//  Created by Mike Haydan on 21/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import UIKit

final class DetailsViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet private weak var detailImageView: DownloaderImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    var model: ImageModel!
    weak var cacheGateway: CacheGateway!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    // MARK: - Private

    func prepareUI() {
        titleLabel.text = model.title
        subtitleLabel.text = model.description
        
        activityIndicatorView.startAnimating()
        detailImageView.dwonloadImagefrom(url: model.imageUrl, downloader: cacheGateway, placeholder: #imageLiteral(resourceName: "placeholder"), complation: { [weak self] (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.activityIndicatorView.stopAnimating()
            }
        })
    }
    
    // MARK: - Public

    func configureWith(model: ImageModel, cacheGateway: CacheGateway) {
        self.model = model
        self.cacheGateway = cacheGateway
    }
}
