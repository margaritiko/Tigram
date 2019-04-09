//
//  ViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 10/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit
import AVFoundation

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserProfileCoreDataServiceDelegate {
    // Main view of the controller
    var profileView: ProfileView! {
        return self.view as? ProfileView
    }
    // Current user
    var user = User()
    // Other fields with information for detecting if there have been any changes
    var descriptionValueBeforeEditing: String?
    var nameValueBeforeEditing: String?
    var isItPossibleToSaveData: Bool = false
    // UIImagePickerController for choosing new userPhoto
    let imagePickerController = UIImagePickerController()
    // The alert allows user to choose between photo library and camera
    let imagePickerAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    // MARK: CoreData UserProfileCoreDataService
    var userProfileCoreDataService: UserProfileCDServiceProtocol!
    // MARK: KeyboardManager
    var keyboardService: KeyboardServiceProtocol!
    // MARK: ViewController Life Cycle
    func reinit(userProfileCDService: UserProfileCDServiceProtocol, keyboardService: KeyboardServiceProtocol) {
        self.userProfileCoreDataService = userProfileCDService
        self.keyboardService = keyboardService
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        settingUpAnAlert()
        profileView.nameTextField.delegate = self
        profileView.descriptionTextView.delegate = self
        userProfileCoreDataService.delegate = self
        profileView.setNonEditableMode()
        // All data updates
        loadUserProfileDataWithCoreData()
        keyboardService.reinit(view: profileView)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardService.beginObservingKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardService.endObservingKeyboard()
    }

    // MARK: Touches
    // If the user has clicked anywhere on the screen - remove the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }

    // MARK: AlertController
    func settingUpAnAlert() {
        // First action in list
        let choosePhotoAction = UIAlertAction(title: "Установить из галлереи", style: .default) { (_: UIAlertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        // Second action in list
        // Please note that you can test the camera only on a real device
        let takePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { (_: UIAlertAction) in
            // When launched, the device will be asked for permission to use the camera
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController.init(title: nil, message: "Камера не поддерживается на данном устройстве", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "ОК", style: .default, handler: {(_: UIAlertAction!) in
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        imagePickerAlert.addAction(choosePhotoAction)
        imagePickerAlert.addAction(takePhotoAction)
        imagePickerAlert.addAction(UIAlertAction(title: NSLocalizedString("Закрыть", comment: "Default action"), style: .cancel))
    }
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        profileView.setImage(with: #imageLiteral(resourceName: "PlaceholderUser"))
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        // Set new user's photo
        profileView.setImage(with: selectedImage)
        user.photo = selectedImage
        user.isPhotoChanged = true
        if !isItPossibleToSaveData {
            profileView.setAbilityToSave()
            isItPossibleToSaveData = true
        }
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }

    // Returns user to main screen
    @IBAction func goBackToChatWindowsButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: Actions
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.present(self.imagePickerAlert, animated: true, completion: nil)
    }
    @IBAction func editButtonClicked(_ sender: Any) {
        if profileView.getEditButtonText() == profileView.titleForEdit {
            profileView.setEditableMode()
        } else {
            profileView.setInabilityToSave()
            isItPossibleToSaveData = false
            saveUserProfileDataWithCoreData()
        }
    }
    @IBAction func textInNameTextFieldDidChanged(_ sender: Any) {
        if profileView.getName() != nameValueBeforeEditing {
            if !isItPossibleToSaveData {
                profileView.setAbilityToSave()
                isItPossibleToSaveData = true
            }
            user.isNameChanged = true
        }
        user.name = profileView.getName()
    }
    // MARK: Work with CoreData
    func loadUserProfileDataWithCoreData() {
        let data = self.userProfileCoreDataService.load()
        // Where 0 is name, 1 is userDescription and 2 is userPhoto
        profileView.setName(with: data?.0)
        profileView.setDescription(with: data?.1)
        profileView.setImage(with: data?.2)
    }
    func saveUserProfileDataWithCoreData() {
        self.userProfileCoreDataService.save(name: profileView.getName(), userDescription: profileView.getDescription(), photo: profileView.getImage())
    }
    // MARK: UserProfileCoreDataManagerDelegate
    func stopSavingWithCD() {
        profileView.stopAnimatingIndicator()
        profileView.setNonEditableMode()
    }
    func startSavingWithCD() {
        profileView.startAnimatingIndicator()
    }
    // MARK: Showing alerts
    func showAlertForUserWith(title: String, message: String?) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameValueBeforeEditing = profileView.getName()
    }
}

extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionValueBeforeEditing = profileView.getDescription()
    }
    func textViewDidChange(_ textView: UITextView) {
        profileView.setButtonWith(color: UIColor.black)
        if profileView.getDescription() != descriptionValueBeforeEditing {
            if !isItPossibleToSaveData {
                profileView.setAbilityToSave()
                isItPossibleToSaveData = true
            }
            user.isDescriptionChanged = true
            user.userDescription = profileView.getDescription()
        }
        user.userDescription = profileView.getDescription()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if profileView.getDescription().isEmpty {
            profileView.setDescription(with: "Bio")
            profileView.setButtonWith(color: UIColor.lightGray)
        }
    }
}
