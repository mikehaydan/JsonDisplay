//
//  ViewController.swift
//  JsonDisplay
//
//  Created by Mike Haydan on 20/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import UIKit

private enum DataViewControllerConstants {
    static let showDetailsSegue = "showDetails"
}

final class DataViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var dataSource: [ImageModel] = []
    private var cacheGateway: CacheGateway!
    private var imageDataGateway: ImagesDataGateway!
    
    private var selectedIndex: Int?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        prepareAPI()
        getDataSource()
        checkOrienation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        checkOrienation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let index = selectedIndex, segue.identifier == DataViewControllerConstants.showDetailsSegue {
            let controller = segue.destination as! DetailsViewController
            let model = dataSource[index]
            controller.configureWith(model: model, cacheGateway: cacheGateway)
        }
    }
    
    // MARK: - Private
    
    private func checkOrienation() {
        let scrollDirection: UICollectionViewScrollDirection
        if UIDevice.current.orientation.isLandscape {
            scrollDirection = .horizontal
        } else {
            scrollDirection = .vertical
        }
        if flowLayout.scrollDirection != scrollDirection {
            flowLayout.scrollDirection = scrollDirection
            flowLayout.invalidateLayout()
        }
    }
    
    private func registerCells() {
        collectionView.register(ImageCollectionViewCell.nib, forCellWithReuseIdentifier: ImageCollectionViewCell.nibName)
    }
    
    private func prepareAPI() {
        let operationQueue = OperationQueue()
        let downloadClient = ApiClientImplementation(urlSessionConfiguration: .default, completionHandlerQueue: operationQueue)
        let imageDownloader = DownloaderGatewayImplementation(apiClient: downloadClient)
        cacheGateway = CacheGatewayImplementation(downloader: imageDownloader)
        imageDataGateway = ImagesDataGatewayImplementation(apiClient: ApiClientImplementation.defaultConfiguration)
    }
    
    private func getDataSource() {
        activityIndicatorView.startAnimating()
        imageDataGateway.getImageData { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.activityIndicatorView.stopAnimating()
            switch result {
            case let .success(response):
                strongSelf.dataSource = response.models
                strongSelf.title = response.title
                strongSelf.collectionView.reloadData()
            case let .failure(error):
                strongSelf.alert(message: error.localizedDescription)
            }
        }
    }
    
    private func reloadDataAnimated() {
        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.reloadSections(IndexSet(integer: 0))
        })
    }
    
    private func reloadCeollectionViewAt(indexPath: IndexPath) {
        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.reloadItems(at: [indexPath])
        })
    }
    
    private func configureCellSizeFrom(collectionViewSize: CGSize, imageSize: CGSize) -> CGSize {
        let minCollectionViewSide: CGFloat
        let imageFirstArg: CGFloat
        let imageSecondArg: CGFloat
        if collectionViewSize.width > collectionViewSize.height {
            minCollectionViewSide = collectionViewSize.height
            imageFirstArg = imageSize.width
            imageSecondArg = imageSize.height
        } else {
            minCollectionViewSide = collectionViewSize.width
            imageFirstArg = imageSize.height
            imageSecondArg = imageSize.width
        }
        
        let proportionalMaxSide = minCollectionViewSide * (imageFirstArg / imageSecondArg)
        
        let width: CGFloat
        let height: CGFloat
        if UIDevice.current.orientation.isLandscape {
            width = proportionalMaxSide
            height = minCollectionViewSide
        } else {
            width = minCollectionViewSide
            height = proportionalMaxSide
        }
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Public

}

// MARK: - UICollectionViewDataSource

extension DataViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.nibName, for: indexPath) as! ImageCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        let cell = cell as! ImageCollectionViewCell
        
        cell.configureWith(model: model, placeholder: #imageLiteral(resourceName: "placeholder"), downloader: cacheGateway, delegate: self)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DataViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = dataSource[indexPath.row]
        let size: CGSize
        
        if let image = model.image {
            size = configureCellSizeFrom(collectionViewSize: collectionView.frame.size, imageSize: image.size)
        } else {
            let minSide = min(collectionView.frame.size.width, collectionView.frame.size.height)
            size = CGSize(width: minSide, height: minSide)
        }
        
        return size
    }
}

// MARK: - UICollectionViewDelegate

extension DataViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: DataViewControllerConstants.showDetailsSegue, sender: nil)
    }
}

// MARK: - ImageCollectionViewCellDelegate

extension DataViewController: ImageCollectionViewCellDelegate {
    
    func downloadingFinishedFor(cell: UICollectionViewCell, image: UIImage) {
        if let indexPath = collectionView.indexPath(for: cell) {
            dataSource[indexPath.row].image = image
            reloadCeollectionViewAt(indexPath: indexPath)
        }
    }
}
