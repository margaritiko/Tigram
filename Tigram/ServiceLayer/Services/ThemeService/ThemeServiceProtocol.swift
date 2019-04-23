//
//  ThemeServiceProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

protocol ThemeServiceProtocol {
    var light: UIColor { get }
    var dark: UIColor { get }
    var champagne: UIColor { get }
    func setTheme(themeName: String, navigationController: UINavigationController?)
    func getColorForName(_ name: String) -> UIColor
    func getCurrentColor() -> UIColor
    func getDefaultColor() -> UIColor
}
