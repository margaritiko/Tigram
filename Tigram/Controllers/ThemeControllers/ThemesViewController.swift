//
//  ThemesViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 05/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

// For compatibility with Objective-C class
protocol ThemesViewControllerDelegate: class {
     func themesViewController(_ controller: ThemesViewController!, didSelectTheme selectedTheme: UIColor!)
}

class ThemesViewController: UIViewController {

    // For compatibility with Objective-C class
    weak var delegate: UIViewController?
    var closureForSettingNewTheme: ((_ color: UIColor?, _ viewController: UIViewController?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ThemesViewController: Swift")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let themeName = UserDefaults.standard.string(forKey: "Theme")
        switch themeName {
        case "light":
            self.view.backgroundColor = ThemeManager().light
        case "dark":
            self.view.backgroundColor = ThemeManager().dark
        case "champagne":
            self.view.backgroundColor = ThemeManager().champagne
        default:
            return
        }
    }
    // Returns user to conversations list screen
    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func lightThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(model?.light, self)
        // The priority is selected
        // It is used for tasks that take some time to complete and do not require immediate feedback
        DispatchQueue.global(qos: .utilities).async {
            UserDefaults.standard.set("light", forKey: "Theme")
        }
    }
    @IBAction func darkThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(model?.dark, self)
        DispatchQueue.global(qos: .utilities).async {
            UserDefaults.standard.set("dark", forKey: "Theme")
        }
    }
    @IBAction func champagneThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(model?.champagne, self)
        DispatchQueue.global(qos: .utilities).async {
            UserDefaults.standard.set("champagne", forKey: "Theme")
        }
    }
}
