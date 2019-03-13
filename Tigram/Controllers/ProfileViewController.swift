//
//  ViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 10/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit
import AVFoundation

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Current user
    var user = User()
    
    var descriptionValueBeforeEditing: String?
    var nameValueBeforeEditing: String?
    var isItPossibleToSaveData: Bool = false
    
    // MARK: Outlets
    @IBOutlet var editButton: UIButton!
    @IBOutlet var gcdButton: UIButton!
    @IBOutlet var operationButton: UIButton!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let imagePickerController = UIImagePickerController()
    
    // The alert allows user to choose between photo library and camera
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // MARK: ViewController life cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Условие не выполнится:
        // В данный момент outlets еще не установлены и имеют значение nil
        // Обращаться к ним нельзя
        if let editButtonFrame = editButton?.frame {
            print("editButton.frame in \(#function): \(editButtonFrame)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        settingUpAnAlert()
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        
        // Обрабатывать значения геометрии в данном методе нельзя, так как они еще некорректны
        // Все constraints не установлены, поэтому текущее значение frame считается без их учета и неверно
        // print("editButton.frame in \(#function): \(editButton!.frame)")
        
        setNonEditableMode()
        setNotificationsForKeyboard()
        
        // All data updates
        getUpdatesForUser()
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
        setDefaultDesignFor(button: gcdButton)
        setDefaultDesignFor(button: operationButton)
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
        alert.addAction(choosePhotoAction)
        alert.addAction(takePhotoAction)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Закрыть", comment: "Default action"), style: .cancel))
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        userPhoto.image = #imageLiteral(resourceName: "PlaceholderUser")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Not an image")
            return
        }
        // Set new user's photo
        userPhoto.image = selectedImage
        user.photo = selectedImage
        if (!isItPossibleToSaveData) {
            setAbilityToSave()
            user.isPhotoChanged = true
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
        // print("Выбери изображение профиля")
        self.present(self.alert, animated: true, completion: nil)
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        setEditableMode()
    }
    
    @IBAction func operationButtonClicked(_ sender: Any) {
        gcdButton.isUserInteractionEnabled = false
        operationButton.isUserInteractionEnabled = false
        saveCurrentDataWith(manager: OperationDataManager())
    }
    
    @IBAction func gcdButtonClicked(_ sender: Any) {
        gcdButton.isUserInteractionEnabled = false
        operationButton.isUserInteractionEnabled = false
        saveCurrentDataWith(manager: GCDDataManager())
    }
    
    @IBAction func textInNameTextFieldDidChanged(_ sender: Any) {
        if (!isItPossibleToSaveData && nameTextField.text != nameValueBeforeEditing) {
            setAbilityToSave()
            user.isNameChanged = true
        }
        user.name = nameTextField.text
    }
    
    // MARK: Different modes
    
    func setNonEditableMode() {
        // Hidden buttons
        gcdButton.isHidden = true
        operationButton.isHidden = true
        cameraButton.isHidden = true
        // Non editable views
        nameTextField.borderStyle = .none
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
        // Just Edit button is visible
        editButton.isHidden = false
    }
    
    func setEditableMode() {
        nameTextField.borderStyle = .roundedRect
        nameTextField.isUserInteractionEnabled = true
        descriptionTextView.isUserInteractionEnabled = true
        cameraButton.isHidden = false
        setInabilityToSave()
        
        // Two buttons are visible now
        editButton.isHidden = true
        operationButton.isHidden = false
        gcdButton.isHidden = false
    }
    
    func setInabilityToSave() {
        isItPossibleToSaveData = false
        
        // You cannot press a button until changes are made
        gcdButton.isEnabled = false
        operationButton.isEnabled = false
        // Visually, you can understand that the button is inactive.
        gcdButton.alpha = 0.4
        operationButton.alpha = 0.4
    }
    
    func setAbilityToSave() {
        isItPossibleToSaveData = true
        
        // Not it is possible to click on button
        gcdButton.isEnabled = true
        operationButton.isEnabled = true
        
        // Visually, you can understand that the button is active.
        gcdButton.alpha = 1
        operationButton.alpha = 1
    }
    
    // MARK: Work with data
    private func getUpdatesForUser() {
        // It is possible to use one of managers to update data
        // GCD Manager
//        GCDDataManager().loadExistingUser { (userToUpdate) in
//            if let user = userToUpdate {
//                self.user = user
//                self.setUpAllDataInUI(user)
//            }
//        }
//
        // Or Operation Manager
//        OperationDataManager().loadExistingUser { (userToUpdate) in
//            if let user = userToUpdate {
//                self.user = user
//                self.setUpAllDataInUI(user)
//            }
//        }
        
        // You can also call the UserManager method directly
        DispatchQueue.global(qos: .userInteractive).async {
            UserManager().getCurrentUser { (userToUpdate) in
                DispatchQueue.main.async {
                    if let user = userToUpdate {
                        self.user = user
                        self.setUpAllDataInUI(user)
                    }
                }
            }
        }
    }
    
    // Updates all UI with new data loaded from files
    private func setUpAllDataInUI(_ user: User) {
        
        nameTextField.text = user.name
        descriptionTextView.text = user.userDescription
        userPhoto.image = user.photo
        
        if descriptionTextView.text == "" {
            descriptionTextView.textColor = UIColor.lightGray
            descriptionTextView.text = "Bio"
        }
        
        if userPhoto.image == nil {
            userPhoto.image = #imageLiteral(resourceName: "PlaceholderUser")
        }
    }
    
    func saveCurrentDataWith(manager: DataManagerProtocol) {
        activityIndicator.startAnimating()
        
        manager.saveGivenUser(user: user) { (success) in
            self.activityIndicator.stopAnimating()
            
            if success {
                self.getUpdatesForUser()
                self.setNonEditableMode()
                self.gcdButton.isUserInteractionEnabled = true
                self.operationButton.isUserInteractionEnabled = true
                let alertVC = UIAlertController.init(title: nil, message: "Данные сохранены", preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)
            }
            else {
                let alertVC = UIAlertController.init(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "OK", style: .cancel) { (action) in
                    self.gcdButton.isUserInteractionEnabled = true
                    self.operationButton.isUserInteractionEnabled = true
                }
                let tryAgainAction = UIAlertAction.init(title: "Повторить", style: .default) { (action) in
                    self.saveCurrentDataWith(manager: manager)
                }
                
                alertVC.addAction(okAction)
                alertVC.addAction(tryAgainAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
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
        if (!isItPossibleToSaveData && descriptionTextView.text != descriptionValueBeforeEditing) {
            setAbilityToSave()
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
