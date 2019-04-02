//
//  UserProfileCoreDataManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 25/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol UserProfileCoreDataManagerDelegate: class {
    func showAlertForUserWith(title: String, message: String?)

    // Activity Indicator control
    func startAnimatingActivityIndicator()
    func stopAnimatingActivityIndicator()
}

class UserProfileCoreDataManager {

    // MARK: Delegate
    weak var delegate: UserProfileCoreDataManagerDelegate?

    // MARK: Saving new data with CoreData
    func save(name: String?, userDescription: String?, photo: UIImage?) {
        // Let's save data in background queue
        let dispatchQueue = DispatchQueue(label: "QueueForSavingUserProfileData", qos: .background)
        dispatchQueue.async {
            // Getting save context
            guard let saveContext = CoreDataManager.instance.getContextWith(name: "save") else {
                self.delegate?.showAlertForUserWith(title: "Ошибка", message: "Возникла проблема, попробуйте снова")
                return
            }
            guard let profileData = UserProfileData.findOrInsertUser(in: saveContext) else {
                self.delegate?.showAlertForUserWith(title: "Ошибка", message: "Не удалось сохранить данные профиля")
                return
            }

            // Activity indicator is a UI part, so we need main queue
            DispatchQueue.main.async {
                self.delegate?.startAnimatingActivityIndicator()
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
                    CoreDataManager.instance.performSave(context: saveContext) {
                        self.delegate?.showAlertForUserWith(title: "", message: "Данные успешно сохранены с CoreData")
                    }
                }
            }

            // Activity indicator is a UI part, so we need main queue
            DispatchQueue.main.async {
                self.delegate?.stopAnimatingActivityIndicator()
            }
        }
    }

    // MARK: Loading Data with CoreData
    func load() -> (String?, String?, UIImage?)? {
        // Getting main context
        guard let mainContext = CoreDataManager.instance.getContextWith(name: "main") else {
            self.delegate?.showAlertForUserWith(title: "Ошибка", message: "Получение данных было прервано")
            return nil
        }
        // Getting all data
        let userProfileData = UserProfileData.findOrInsertUser(in: mainContext)
        var photo: UIImage?
        if let userPhotoData = userProfileData?.photo {
            photo = UIImage(data: userPhotoData)
        }

        return (userProfileData?.name,
                userProfileData?.userDescription,
                photo)
    }
}
