//
//  UserProfileCDManagerProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

protocol UserProfileCDServiceProtocol {
    var delegate: UserProfileCoreDataServiceDelegate? {get set}
    func save(name: String?, userDescription: String?, photo: UIImage?)
    func load() -> (String?, String?, UIImage?)?
}
