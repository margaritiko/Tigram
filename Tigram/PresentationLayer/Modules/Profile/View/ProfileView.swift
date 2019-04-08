//
//  ProfileView.swift
//  Tigram
//
//  Created by Маргарита Коннова on 06/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class ProfileView: UIView {

    // MARK: Outlets
    @IBOutlet var editButton: UIButton!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    // MARK: Titles for editButton
    let titleForEdit = "Редактировать с CoreData"
    let titleForSave = "Сохранить при помощи CoreData"

    override func awakeFromNib() {
        // userPhoto
        userPhoto.layer.cornerRadius = cameraButton.bounds.height / 2
        // cameraButton
        cameraButton.layer.cornerRadius = cameraButton.bounds.height / 2
        let paddings = cameraButton.bounds.height * 0.22
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: paddings, left: paddings, bottom: paddings, right: paddings)
        // descriptionTextView: setting font size
        descriptionTextView.font = descriptionTextView.font?.withSize(cameraButton.bounds.height * 0.2)
        // Default design for all buttons from stack
        setDefaultDesignFor(button: editButton)
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

    // MARK: Getters
    func getImage() -> UIImage? {
        return userPhoto.image
    }
    func getDescription() -> String {
        return descriptionTextView.text
    }
    func getName() -> String {
        return nameTextField.text ?? "Name"
    }
    func getEditButtonText() -> String {
        return editButton.titleLabel?.text ?? ""
    }

    // MARK: Setters
    func setImage(with image: UIImage?) {
        userPhoto.image = image ?? #imageLiteral(resourceName: "PlaceholderUser")
    }
    func setName(with name: String?) {
        nameTextField.text = name ?? "Name"
    }
    func setDescription(with description: String?) {
        descriptionTextView.text = description ?? "Description"
    }

    // MARK: Colors setter
    func setButtonWith(color: UIColor) {
        descriptionTextView.textColor = color
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
        // You cannot press a button until changes are made
        editButton.isEnabled = false
        // Visually, you can understand that the button is inactive.
        editButton.alpha = 0.4
    }
    func setAbilityToSave() {
        // Not it is possible to click on button
        editButton.isEnabled = true
        // Visually, you can understand that the button is active.
        editButton.alpha = 1
    }
    func startAnimatingIndicator() {
        activityIndicator.startAnimating()
    }
    func stopAnimatingIndicator() {
        activityIndicator.stopAnimating()
    }
}
