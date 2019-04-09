//
//  KeyboardManagerProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 07/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardServiceProtocol {
    func reinit(view: UIView)
    func beginObservingKeyboard()
    func endObservingKeyboard()
}
