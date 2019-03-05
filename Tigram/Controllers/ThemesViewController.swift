//
//  ThemesViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 05/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

// For compatibility with Objective-C class
protocol ThemesViewControllerDelegate {
     func themesViewController(_ controller: ThemesViewController!, didSelectTheme selectedTheme: UIColor!)
}


class ThemesViewController: UIViewController {

    // For compatibility with Objective-C class
    var delegate: UIViewController?
    var closureForSettingNewTheme: ((_ color: UIColor?, _ viewController: UIViewController?) -> Void)?
    var model: Themes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ThemesViewController: Swift")

        let lightColor: UIColor = .white
        let darkColor: UIColor = UIColor.init(red: 83 / 256.0, green: 103 / 256.0, blue: 120 / 256.0, alpha: 1.0)
        let champagneColor: UIColor = UIColor.init(red: 244 / 256.0, green: 217 / 256.0, blue: 73 / 256.0, alpha: 1.0)
        model = Themes(themesWithFirstColor: lightColor, secondColor: darkColor, thirdColor: champagneColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        switch themeName {
        case "light":
            self.view.backgroundColor = UIColor.white
        case "dark":
            // let darkColorForTheme = UIColor.init(red: 83 / 256.0, green: 103 / 256.0, blue: 120 / 256.0, alpha: 1.0)
            self.view.backgroundColor = model?.dark
        case "champagne":
            // let champagneColorForTheme = UIColor.init(red: 244 / 256.0, green: 217 / 256.0, blue: 73 / 256.0, alpha: 1.0)
            self.view.backgroundColor = model?.champagne
        default:
            NSLog("No valid name for theme")
        }
    }
    
    // Returns user to conversations list screen
    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func lightThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(model?.light, self)
        UserDefaults.standard.set("light", forKey: "Theme")
    }
    
    @IBAction func darkThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(model?.dark, self)
        UserDefaults.standard.set("dark", forKey: "Theme")
    }
    
    @IBAction func champagneThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(model?.champagne, self)
        UserDefaults.standard.set("champagne", forKey: "Theme")
    }
}
