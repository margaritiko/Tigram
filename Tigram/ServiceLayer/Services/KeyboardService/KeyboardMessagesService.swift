//
//  KeyboardManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 07/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

class KeyboardMessagesService: KeyboardServiceProtocol {
    // MARK: Fields
    var view: UIView?
    var keyboardIsShowing: Bool = false

    // MARK: Functions
    func reinit(view: UIView) {
        self.view = view
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

    @objc private func keyboardWillShow(notification: NSNotification) {
        if !keyboardIsShowing {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.view?.bounds.origin.y = keyboardRectangle.height
                keyboardIsShowing = true
            }
        }
    }
    @objc private func keyboardDidHide(notification: NSNotification) {
        if keyboardIsShowing {
            self.view?.bounds.origin.y = 0
            keyboardIsShowing = false
        }
    }
}
