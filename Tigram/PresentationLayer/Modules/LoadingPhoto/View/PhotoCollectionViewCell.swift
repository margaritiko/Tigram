//
//  PhotoCollectionViewCell.swift
//  Tigram
//
//  Created by Маргарита Коннова on 12/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    // MARK: Fields
    var isCurrentImageIsPlaceholder: Bool = true

    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
}
