//
//  User.swift
//  Tigram
//
//  Created by Маргарита Коннова on 12/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

// Need override an empty init so inherit from NSObject
class User: NSObject {
    var name: String?
    var userDescription: String?
    var photo: UIImage?
    
    var isNameChanged: Bool = false
    var isDescriptionChanged: Bool = false
    var isPhotoChanged: Bool = false
    
    init(name: String?, description: String?, photo: UIImage?) {
        self.name = name
        self.userDescription = description
        self.photo = photo
    }
    
    override init() {
    }
}
