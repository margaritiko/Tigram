//
//  UserManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 12/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

//protocol UserManagerProtocol {
//    func saveUser(user: User, completion: @escaping (_ success: Bool) -> Void)
//    func getUser(completion: @escaping (_ user: User?) -> Void)
//}

class UserManager {
    
    // Names of files in which we are going to save the data
    private let userNameFileName = "userName.txt"
    private let userDescriptionFileName = "userDescription.txt"
    private let userPhotoFileName = "userPhoto.png"
    
    func saveGivenUser(user: User, completion: @escaping (Bool) -> Void) {
        do {
            let filePath = self.getDocumentsDirectory()
            
            // Checks if we need to save name
            if user.isNameChanged, let name = user.name {
                // The data is written directly to given location
                try name.write(to: filePath.appendingPathComponent(userNameFileName), atomically: false, encoding: String.Encoding.utf8)
            }
            // Checks if we need to save description
            if user.isDescriptionChanged, let description = user.userDescription {
                // The data is written directly to given location
                try description.write(to: filePath.appendingPathComponent(userDescriptionFileName), atomically: false, encoding: String.Encoding.utf8)
            }
            // Checks if we need to save photo
            if user.isPhotoChanged, let photo = user.photo {
                let data = photo.pngData()
                // Option is a hint to write data to an auxiliary file first and then exchange the files
                try data?.write(to: filePath.appendingPathComponent(userPhotoFileName), options: .atomic)
            }
        
            user.isNameChanged = false
            user.isDescriptionChanged = false
            user.isPhotoChanged = false
            completion(true)
        }
        catch {
            print("ERROR: \(error)")
            completion(false)
        }
    }
    
    func getCurrentUser(completion: @escaping (User?) -> Void) {
        do {
            // Creates an empty user
            let user: User = User()
            // Gets a location of Documents Directory
            let path = getDocumentsDirectory()
            user.name = try String(contentsOf: path.appendingPathComponent(userNameFileName))
            user.userDescription = try String(contentsOf: path.appendingPathComponent(userDescriptionFileName))
            user.photo = UIImage(contentsOfFile: path.appendingPathComponent(userPhotoFileName).path)
            
            completion(user)
        }
        catch {
            // Creates a new user
            completion(createNewUser())
        }
    }
    
    // Creates a new user with information about developer and saves all data to files
    private func createNewUser() -> User {
        let user = User(name: "Margarita Konnova",
                        description: "HSE Student\niOS Developer",
                        photo: #imageLiteral(resourceName: "PlaceholderUser"))
        user.isPhotoChanged = true
        user.isDescriptionChanged = true
        user.isNameChanged = true
        saveGivenUser(user: user) { (success) in print("Save default user: \(success)") }
        
        return user
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

