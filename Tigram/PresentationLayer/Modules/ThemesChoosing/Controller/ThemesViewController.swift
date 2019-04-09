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
    var themesService: ThemeServiceProtocol!
    var themesView: ThemesView! {
        return self.view as? ThemesView
    }

    // For compatibility with Objective-C class
    weak var delegate: UIViewController?
    var closureForSettingNewTheme: ((_ color: UIColor?, _ viewController: UIViewController?) -> Void)?

    // MARK: Life Cycle
    func reinit(themesService: ThemeServiceProtocol) {
        self.themesService = themesService
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let themeName = UserDefaults.standard.string(forKey: "Theme")
        switch themeName {
        case "light":
            themesView.changeBackgroundColorTo(themesService.light)
        case "dark":
            themesView.changeBackgroundColorTo(themesService.dark)
        case "champagne":
            themesView.changeBackgroundColorTo(themesService.champagne)
        default:
            return
        }
    }
    // Returns user to conversations list screen
    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func lightThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(themesService.light, self)
        themesView.changeBackgroundColorTo(themesService.light)
        // The priority is selected
        // It is used for tasks that take some time to complete and do not require immediate feedback
        DispatchQueue.global(qos: .utility).async {
            UserDefaults.standard.set("light", forKey: "Theme")
        }
    }
    @IBAction func darkThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(themesService.dark, self)
        themesView.changeBackgroundColorTo(themesService.dark)
        DispatchQueue.global(qos: .utility).async {
            UserDefaults.standard.set("dark", forKey: "Theme")
        }
    }
    @IBAction func champagneThemeButtonClicked(_ sender: Any) {
        closureForSettingNewTheme?(themesService.champagne, self)
        themesView.changeBackgroundColorTo(themesService.champagne)
        DispatchQueue.global(qos: .utility).async {
            UserDefaults.standard.set("champagne", forKey: "Theme")
        }
    }
}
