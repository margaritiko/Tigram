//
//  KeyboardProfileManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 07/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

class KeyboardProfileService: KeyboardServiceProtocol {
    // MARK: Fields
    let profileView: ProfileView!

    // MARK: Functions
    init(view: ProfileView) {
        self.profileView = view
    }
    // MARK: KeyboardManagerProtocol
    func beginObservingKeyboard() {
        // Adding events to pick up view when the keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func endObservingKeyboard() {
        // Deleting events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Changes the position of the view to avoid overlapping with keyboard
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.profileView.bounds.origin.y = keyboardRectangle.height * 0.5
        }
    }
    // Moves the objects down after the keyboard disappears
    @objc func keyboardDidHide(notification: NSNotification) {
        self.profileView.bounds.origin.y = 0
    }
}
