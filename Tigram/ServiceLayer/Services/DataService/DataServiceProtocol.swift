//
//  DataManagerProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 12/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

// Protocol for optimizing the choice of instance of the appropriate class
protocol DataServiceProtocol {
    // Saves all data
    func saveGivenUser(user: User, completion: @escaping (_ success: Bool) -> Void)
    // Loads all data
    func loadExistingUser(completion: @escaping (_ user: User?) -> Void)
}
