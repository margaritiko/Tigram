//
//  ViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 10/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit
import AVFoundation

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserProfileCoreDataManagerDelegate {
    // Current user
    var user = User()
    
    // CoreData UserProfileCoreDataManager
    let userProfileCoreDataManager = UserProfileCoreDataManager()
    
    // Titles for editButton
    let titleForEdit = "Редактировать с CoreData"
    let titleForSave = "Сохранить при помощи CoreData"
    
    // Other fields with information for detecting if there have been any changes
    var descriptionValueBeforeEditing: String?
    var nameValueBeforeEditing: String?
    var isItPossibleToSaveData: Bool = false
    
    // MARK: Outlets
    @IBOutlet var editButton: UIButton!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // UIImagePickerController for choosing new userPhoto
    let imagePickerController = UIImagePickerController()
    
    // The alert allows user to choose between photo library and camera
    let imagePickerAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // MARK: ViewController Life Cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        settingUpAnAlert()
        
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        userProfileCoreDataManager.delegate = self
        
        setNonEditableMode()
        setNotificationsForKeyboard()
        
        // All data updates
        loadUserProfileDataWithCoreData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // The right place for work with geometry
        // userPhoto
        userPhoto.layer.cornerRadius = cameraButton.bounds.height / 2
        // cameraButton
        cameraButton.layer.cornerRadius = cameraButton.bounds.height / 2
        let cameraButtonPaddings = cameraButton.bounds.height * 0.22
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: cameraButtonPaddings, left: cameraButtonPaddings, bottom: cameraButtonPaddings, right: cameraButtonPaddings)
        
        // descriptionTextView: setting font size
        descriptionTextView.font = descriptionTextView.font?.withSize(cameraButton.bounds.height * 0.2)
        
        // Default design for all buttons from stack
        setDefaultDesignFor(button: editButton)
    }
    
    // If the user has clicked anywhere on the screen - remove the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: Design
    func setDefaultDesignFor(button: UIButton) {
        // Edit some button's design details
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        
        let buttonPaddings = cameraButton.bounds.height * 0.15
        
        button.layer.cornerRadius = buttonPaddings
        button.contentEdgeInsets = UIEdgeInsets(top: buttonPaddings, left: 0, bottom: buttonPaddings, right: 0)
        // Setting font size
        button.titleLabel?.font = button.titleLabel?.font.withSize(cameraButton.bounds.height * 0.17)
    }
    
    
    // Notification when keyboard show
    func setNotificationsForKeyboard ()  {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    // Changes the position of the view to avoid overlapping with keyboard
    @objc func keyboardWasShown(notification: NSNotification)
    {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.view.bounds.origin.y = keyboardRectangle.height * 0.5
        }
    }
    
    // Moves the objects down after the keyboard disappears
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        self.view.bounds.origin.y = 0
        descriptionValueBeforeEditing = descriptionTextView.text
        nameValueBeforeEditing = nameTextField.text
    }
    
    // MARK: AlertController
    func settingUpAnAlert() {
        // First action in list
        let choosePhotoAction = UIAlertAction(title: "Установить из галлереи", style: .default) { (action:UIAlertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        // Second action in list
        // Please note that you can test the camera only on a real device
        let takePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { (action: UIAlertAction) in
            // When launched, the device will be asked for permission to use the camera
            if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            else {
                let alertController = UIAlertController.init(title: nil, message: "Камера не поддерживается на данном устройстве", preferredStyle: .alert)
                
                let okAction = UIAlertAction.init(title: "ОК", style: .default, handler: {(alert: UIAlertAction!) in
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
        userPhoto.image = #imageLiteral(resourceName: "PlaceholderUser")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        // Set new user's photo
        userPhoto.image = selectedImage
        user.photo = selectedImage
        user.isPhotoChanged = true
        if (!isItPossibleToSaveData) {
            setAbilityToSave()
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
        if (editButton.titleLabel?.text == titleForEdit) {
            setEditableMode()
        }
        else {
            setInabilityToSave()
            saveUserProfileDataWithCoreData()
        }
    }
    
    @IBAction func textInNameTextFieldDidChanged(_ sender: Any) {
        if (nameTextField.text != nameValueBeforeEditing) {
            if (!isItPossibleToSaveData) {
                setAbilityToSave()
            }
            user.isNameChanged = true
        }
        user.name = nameTextField.text
    }
    
    // MARK: Work with CoreData
    
    func loadUserProfileDataWithCoreData() {
        let data = self.userProfileCoreDataManager.load()
        
        // Where 0 is name, 1 is userDescription and 2 is userPhoto
        self.nameTextField.text = data?.0
        self.descriptionTextView.text = data?.1
        self.userPhoto.image = data?.2
    }
    
    func saveUserProfileDataWithCoreData() {
        self.userProfileCoreDataManager.save(name: nameTextField.text, userDescription: descriptionTextView.text, photo: userPhoto.image)
    }
    
    // MARK: UserProfileCoreDataManagerDelegate
    
    func stopAnimatingActivityIndicator() {
        self.activityIndicator.stopAnimating()
        setNonEditableMode()
    }
    
    func startAnimatingActivityIndicator() {
        self.activityIndicator.startAnimating()
    }

    // MARK: Different modes
    
    func setNonEditableMode() {
        // Hidden buttons
        cameraButton.isHidden = true
        
        // Non editable views
        nameTextField.borderStyle = .none
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
        
        // Now text of button is "Edit"
        editButton.setTitle(titleForEdit, for: .normal)
        
        // Now we can click on it
        editButton.isEnabled = true
        
        // And also now we see that we can click on it
        editButton.alpha = 1
    }
    
    func setEditableMode() {
        nameTextField.borderStyle = .roundedRect
        nameTextField.isUserInteractionEnabled = true
        descriptionTextView.isUserInteractionEnabled = true
        cameraButton.isHidden = false
        setInabilityToSave()
        
        // Now button has text "Save"
        editButton.setTitle(titleForSave, for: .normal)
    }
    
    func setInabilityToSave() {
        isItPossibleToSaveData = false
        
        // You cannot press a button until changes are made
        editButton.isEnabled = false
        // Visually, you can understand that the button is inactive.
        editButton.alpha = 0.4
    }
    
    func setAbilityToSave() {
        isItPossibleToSaveData = true
        
        // Not it is possible to click on button
        editButton.isEnabled = true
        // Visually, you can understand that the button is active.
        editButton.alpha = 1
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
        nameValueBeforeEditing = nameTextField.text
    }
    
}

extension ProfileViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionValueBeforeEditing = descriptionTextView.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionTextView.textColor = UIColor.black
        if (descriptionTextView.text != descriptionValueBeforeEditing) {
            if (!isItPossibleToSaveData) {
                setAbilityToSave()
            }
            user.isDescriptionChanged = true
            user.userDescription = descriptionTextView.text
        }
        user.userDescription = descriptionTextView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Bio"
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
}
