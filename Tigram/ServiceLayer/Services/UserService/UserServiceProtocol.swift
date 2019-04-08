//
//  UserServiceProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 07/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

protocol UserServiceProtocol {
    func saveGivenUser(user: User, completion: @escaping (Bool) -> Void)
    func getCurrentUser(completion: @escaping (User?) -> Void)
    func getDocumentsDirectory() -> URL
}
