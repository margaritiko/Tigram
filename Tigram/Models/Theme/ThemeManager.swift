//
//  ThemeManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 13/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

public class ThemeManager {
    let light = UIColor.white
    let dark = UIColor.init(red: 83 / 256.0, green: 103 / 256.0, blue: 120 / 256.0, alpha: 1.0)
    let champagne = UIColor.init(red: 244 / 256.0, green: 217 / 256.0, blue: 73 / 256.0, alpha: 1.0)

    public func setTheme(themeName: String, navigationController: UINavigationController?) {
        switch themeName {
        case "light":
            navigationController?.navigationBar.backgroundColor = UIColor.white
            UINavigationBar.appearance().backgroundColor = UIColor.white
        case "dark":
            navigationController?.navigationBar.backgroundColor = dark
            UINavigationBar.appearance().backgroundColor = dark
        case "champagne":
            navigationController?.navigationBar.backgroundColor = champagne
            UINavigationBar.appearance().backgroundColor = champagne
        default:
            return
        }
    }

    func getColorForName(_ name: String) -> UIColor {
        switch name {
        case "light":
            return light
        case "dark":
            return dark
        case "champagne":
            return champagne
        default:
            return light
        }
    }
}
