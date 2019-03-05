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

    // MARK: Outlets
    @IBOutlet var editButton: UIButton?
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
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
        
        // Edit some button's design details
        editButton!.layer.borderColor = UIColor.black.cgColor
        editButton!.layer.borderWidth = 1
        
        // Обрабатывать значения геометрии в данном методе нельзя, так как они еще некорректны
        // Все constraints не установлены, поэтому текущее значение frame считается без их учета и неверно
        // print("editButton.frame in \(#function): \(editButton!.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // На данном этапе все constraints установлены
        // Значение frame отличается от предыдущего, так как оно уже корректно и рассчитано с учетом всех constraints уже для той модели iPhone, на которой запускается приложение
        // print("editButton.frame in \(#function): \(editButton!.frame)")
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
        // editButton
        let editButtonPaddings = cameraButton.bounds.height * 0.15
        editButton!.layer.cornerRadius = editButtonPaddings
        editButton!.contentEdgeInsets = UIEdgeInsets(top: editButtonPaddings, left: 0, bottom: editButtonPaddings, right: 0)
        // setting font size
        editButton?.titleLabel?.font = editButton?.titleLabel?.font.withSize(cameraButton.bounds.height * 0.17)
        
        // descriptionLabel: setting font size
        descriptionLabel.font = descriptionLabel.font.withSize(cameraButton.bounds.height * 0.2)
    }
    
    // MARK: Actions
    @IBAction func cameraButtonClicked(_ sender: Any) {
        // print("Выбери изображение профиля")
        self.present(self.alert, animated: true, completion: nil)
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
        userPhoto.image = nil
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
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }

    // Returns user to main screen
    @IBAction func goBackToChatWindowsButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
