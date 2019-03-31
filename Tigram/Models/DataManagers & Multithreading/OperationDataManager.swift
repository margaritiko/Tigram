//
//  OperationDataManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 12/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

class SaveOperation: Operation {
    var user: User
    var success: Bool?
    var completion: (Bool) -> Void
    init(user: User, completion: @escaping (Bool) -> Void) {
        self.user = user
        self.completion = completion
    }
    override func main() {
        UserManager().saveGivenUser(user: user, completion: { (success) in
            OperationQueue.main.addOperation({self.completion(success)})
        })
    }
}

class LoadOperation: Operation {
    var success: Bool?
    var completion: (User?) -> Void
    init(completion: @escaping (User?) -> Void) {
        self.completion = completion
    }
    override func main() {
        UserManager().getCurrentUser(completion: { (user) in
            // Serial Main queue
            OperationQueue.main.addOperation {self.completion(user)}
        })
    }
}

class OperationDataManager: DataManagerProtocol {
    func saveGivenUser(user: User, completion: @escaping (Bool) -> Void) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        let saveOperation = SaveOperation(user: user, completion: completion)
        queue.addOperation(saveOperation)
    }
    func loadExistingUser(completion: @escaping (User?) -> Void) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3

        let loadOperation = LoadOperation(completion: completion)
        queue.addOperation(loadOperation)
    }
}
