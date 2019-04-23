//
//  ThemeManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 13/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

public class ThemeService: ThemeServiceProtocol {
    // MARK: Fields
    let light = UIColor.white
    let blueForWhiteTheme = UIColor(red: 58 / 256.0, green: 123 / 256.0, blue: 240 / 256.0, alpha: 0.8)
    let dark = UIColor.init(red: 83 / 256.0, green: 103 / 256.0, blue: 120 / 256.0, alpha: 0.8)
    let champagne = UIColor.init(red: 244 / 256.0, green: 217 / 256.0, blue: 73 / 256.0, alpha: 1.0)

    // MARK: Other functions
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

    func getCurrentColor() -> UIColor {
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        switch themeName {
        case "light":
            return blueForWhiteTheme
        case "dark":
            return dark
        case "champagne":
            return champagne
        default:
            return blueForWhiteTheme
        }
    }

    func getDefaultColor() -> UIColor {
        return UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
    }
}
