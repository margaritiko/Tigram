//
//  UserProfileCoreDataManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 25/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol UserProfileCoreDataServiceDelegate: class {
    func showAlertForUserWith(title: String, message: String?)

    // Activity Indicator control
    func startSavingWithCD()
    func stopSavingWithCD()
}

class UserProfileCDService: UserProfileCDServiceProtocol {
    // MARK: Fields
    let coreDataManager: CoreDataManagerProtocol
    weak var delegate: UserProfileCoreDataServiceDelegate?

    // MARK: Life Cycle
    init(manager: CoreDataManagerProtocol) {
        // Creates CoreData manager
        coreDataManager = manager
    }
    // MARK: Saving new data with CoreData
    func save(name: String?, userDescription: String?, photo: UIImage?) {
        // Getting save context
        guard let saveContext = self.coreDataManager.getSaveContext() else {
            self.delegate?.showAlertForUserWith(title: "Ошибка", message: "Возникла проблема, попробуйте снова")
            return
        }
        guard let profileData = UserProfileData.findOrInsertUser(in: saveContext, with: self.coreDataManager) else {
            self.delegate?.showAlertForUserWith(title: "Ошибка", message: "Не удалось сохранить данные профиля")
            return
        }

        // Activity indicator is a UI part, so we need main queue
        DispatchQueue.main.async {
            self.delegate?.startSavingWithCD()
        }

        // Send messages to managed objects with current context and waiting for finish
        saveContext.performAndWait {
            // Checks if there have been any changes
            // Comparison of recorded data with given
            if profileData.name != name {
                profileData.name = name
            }
            if profileData.userDescription != userDescription {
                profileData.userDescription = userDescription
            }
            if let userPhoto = photo, let userPhotoData = userPhoto.jpegData(compressionQuality: 1), profileData.photo != userPhotoData {
                profileData.photo = userPhotoData
            }

            if !saveContext.hasChanges {
                self.delegate?.showAlertForUserWith(title: "Сохранение было остановлено", message: "Причина: ничего не было изменено")
            } else {
                self.coreDataManager.performSave(context: saveContext) {
                    self.delegate?.showAlertForUserWith(title: "", message: "Данные успешно сохранены с CoreData")
                }
            }
        }

        // Activity indicator is a UI part, so we need main queue
        DispatchQueue.main.async {
            self.delegate?.stopSavingWithCD()
        }

    }

    // MARK: Loading Data with CoreData
    func load() -> (String?, String?, UIImage?)? {
        // Getting main context
        guard let mainContext = coreDataManager.getMainContext() else {
            self.delegate?.showAlertForUserWith(title: "Ошибка", message: "Получение данных было прервано")
            return nil
        }
        // Getting all data
        let userProfileData = UserProfileData.findOrInsertUser(in: mainContext, with: coreDataManager)
        var photo: UIImage?
        if let userPhotoData = userProfileData?.photo {
            photo = UIImage(data: userPhotoData)
        }

        return (userProfileData?.name,
                userProfileData?.userDescription,
                photo)
    }
}
