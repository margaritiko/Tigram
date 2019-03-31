//
//  GCDDataManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 12/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

class GCDDataManager: DataManagerProtocol {

    func saveGivenUser(user: User, completion: @escaping (_ success: Bool) -> Void) {
        // Concurrent high priority queue
        let userInitiatedQueue = DispatchQueue.global(qos: .userInitiated)
        // Async photo saving
        userInitiatedQueue.async {
            // Passes to the function a closure that needs to be executed after saving user
            UserManager().saveGivenUser(user: user, completion: { (success) in
                // Serial Main queue
                DispatchQueue.main.async {
                    completion(success)
                }
            })
        }
    }

    func loadExistingUser(completion: @escaping (User?) -> Void) {
        // Concurrent high priority queue
        let userInitiatedQueue = DispatchQueue.global(qos: .userInitiated)
        // Async photo saving
        userInitiatedQueue.async {
            // Passes to the function a closure that needs to be executed after loading user
            UserManager().getCurrentUser(completion: { (user) in
                // Serial Main queue
                DispatchQueue.main.async {
                    completion(user)
                }
            })
        }
    }
}
