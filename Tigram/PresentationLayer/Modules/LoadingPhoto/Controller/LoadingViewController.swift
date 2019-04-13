//
//  LoadingViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 12/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

protocol LoadingIllustrationsVCDelegate: class {
    func userSelected(image: UIImage)
}

class LoadingIllustrationsViewController: UIViewController {

    // MARK: Services
    private var networkService: NetworkServiceProtocol!
    private var requestSender: IRequestSender = RequestSender()

    // MARK: Delegate
    weak var delegate: LoadingIllustrationsVCDelegate?

    // MARK: Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    // MARK: Life Cycle
    func reinit(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        startGettingIllustrationsFromInternet()
    }

    // MARK: Fields
    // Saving illustrations
    private var illustrations = [Int: UIImage]()
    // Design
    private let numberOfImagesPerRow: CGFloat = 3
    private let insets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    // MARK: Actions
    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }
}

// Loading images from Internet
extension LoadingIllustrationsViewController {
    func startGettingIllustrationsFromInternet() {
        // Starts Activity Indicator
        activityIndicator.startAnimating()
        networkService.loadIllustrationsDetails {
            DispatchQueue.main.async {
                // Stops Activity Indicator
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
    }

    func startLoadingIllustrations(indexPathRow row: Int) {
        networkService.loadIllustration(for: row) { image in
            DispatchQueue.main.async {
                self.illustrations[row] = image.illustration
                self.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
            }
        }
    }
}

extension LoadingIllustrationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.top
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Increased by one because thare are one more free space
        let freeSpace = insets.top * (numberOfImagesPerRow + 1)
        // Gets width for each item in collection view
        let width = (collectionView.frame.width - freeSpace) / numberOfImagesPerRow
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
}

extension LoadingIllustrationsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Gets cell which was selected by user
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
        // Checks if current image in cell is placeholder
        if cell?.isCurrentImageIsPlaceholder ?? true {
            return
        }
        // Gets image from cell
        if let image = cell?.imageView.image {
            delegate?.userSelected(image: image)
            dismiss(animated: true)
        }
    }
}

extension LoadingIllustrationsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return networkService.numberOfIllustrations()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        if let image = illustrations[indexPath.row] {
            cell.imageView.image = image
            cell.isCurrentImageIsPlaceholder = false
        } else {
            // Setting placeholder image
            cell.imageView.image = #imageLiteral(resourceName: "CatPlaceholder")
            cell.isCurrentImageIsPlaceholder = true
            startLoadingIllustrations(indexPathRow: indexPath.row)
        }
        // Download more illustrations after scrolling to the end of screen
        if indexPath.row == networkService.numberOfIllustrations() - 1 {
            startGettingIllustrationsFromInternet()
        }
        return cell
    }
}
