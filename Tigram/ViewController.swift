//
//  ViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 10/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Outlets
    @IBOutlet weak var editButton: UIButton?
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
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
        
        // Edit button's design details
        editButton!.layer.cornerRadius = 10
        editButton!.layer.borderColor = UIColor.black.cgColor
        editButton!.layer.borderWidth = 1
        editButton!.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        // Обрабатывать значения геометрии в данном методе нельзя, так как они еще некорректны
        // Все constraints не установлены, поэтому текущее значение frame считается без их учета и неверно
        print("editButton.frame in \(#function): \(editButton!.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // На данном этапе все constraints установлены
        // Значение frame отличается от предыдущего, так как оно уже корректно и рассчитано с учетом всех constraints
        print("editButton.frame in \(#function): \(editButton!.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // The right place for work with geometry
        userPhoto.layer.cornerRadius = cameraButton.bounds.height / 2
        cameraButton.layer.cornerRadius = cameraButton.bounds.height / 2
        let paddings = cameraButton.bounds.height * 0.22
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: paddings, left: paddings, bottom: paddings, right: paddings)
    }
    
    // MARK: Actions
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: AlertController
    func settingUpAnAlert() {
        // First action in list
        let choosePhotoAction = UIAlertAction(title: "Установить из галлереи", style: .default) { (action:UIAlertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        // Second action in list
        let takePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { (action:UIAlertAction) in
            // When launched, the device will be asked for permission to use the camera
            
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        alert.addAction(choosePhotoAction)
        alert.addAction(takePhotoAction)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Закрыть", comment: "Default action"), style: .cancel))
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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

}
