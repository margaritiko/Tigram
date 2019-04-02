//
//  UserProfileData.swift
//  Tigram
//
//  Created by Маргарита Коннова on 25/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import CoreData

extension UserProfileData {

    // MARK: CoreData
    // Forming a query from the query pattern
    static func getFetchRequest() -> NSFetchRequest<UserProfileData> {
        let fetchRequest = NSFetchRequest<UserProfileData>(entityName: "UserProfileData")
        return fetchRequest
    }
    // Creating default data for empty user
    static func insertNewUser(in context: NSManagedObjectContext) -> UserProfileData? {
        if let userProfileData = NSEntityDescription.insertNewObject(forEntityName: "UserProfileData", into: context) as? UserProfileData {
            userProfileData.name = "Margarita Konnova"
            userProfileData.userDescription = "IOS Developer\nHSE Student"
            userProfileData.photo = UIImage(named: "PlaceholderUser")?.pngData()
            return userProfileData
        }
        return nil
    }
    // In order to get an object from the repository, we should execute a query to it.

    static func findOrInsertUser(in context: NSManagedObjectContext, userId: String? = nil) -> UserProfileData? {
        var user: UserProfileData?
        var fetchRequest: NSFetchRequest<UserProfileData>
        if let userId = userId, let request = CoreDataManager.instance.getUserFetchRequest(named: "UserWithId", with: userId) {
            fetchRequest = request
        } else {
            fetchRequest = UserProfileData.getFetchRequest()
        }
        // Waiting for finish
        context.performAndWait {
            do {
                let results = try context.fetch(fetchRequest)
                if let foundUser = results.first {
                    user = foundUser
                }
            } catch {
                print("Failed to fetch UserProfileData: \(error)")
            }
        }
        if user == nil {
            user = UserProfileData.insertNewUser(in: context)
        }
        return user
    }
}
