//
//  UserProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol UserProtocol {
    var name: String? {get set}
    var userDescription: String? {get set}
    var photo: UIImage? {get set}
}
