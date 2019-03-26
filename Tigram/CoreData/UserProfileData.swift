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
    static func fetchRequestProfileData() -> NSFetchRequest<UserProfileData> {
        let templateName = "UserProfileData"
        let fetchRequest = NSFetchRequest<UserProfileData>(entityName: templateName)
        return fetchRequest
    }
    
    // Creating default data for empty user
    static func insertUserProfileData(in context: NSManagedObjectContext) -> UserProfileData? {
        if let userProfileData = NSEntityDescription.insertNewObject(forEntityName: "UserProfileData", into: context) as? UserProfileData {
            userProfileData.name = "Margarita Konnova"
            userProfileData.userDescription = "IOS Developer\nHSE Student"
            userProfileData.photo = UIImage(named: "PlaceholderUser")?.pngData()
            
            return userProfileData
        }
        return nil
    }
    
    // In order to get an object from the repository, we should execute a query to it.
    static func findOrInsertUserProfileData(in context: NSManagedObjectContext) -> UserProfileData? {
        var userProfileData: UserProfileData?
        let fetchRequest = UserProfileData.fetchRequestProfileData()
        
        // Waiting for finish
        context.performAndWait {
            do {
                let results = try context.fetch(fetchRequest)
                assert(results.count < 2, "Multiple UserProfileData found!")
                if let foundUser = results.first {
                    userProfileData = foundUser
                }
            } catch {
                print("Failed to fetch UserProfileData: \(error)")
            }
        }
        
        if userProfileData == nil {
            userProfileData = UserProfileData.insertUserProfileData(in: context)
        }
        
        return userProfileData
    }
}
