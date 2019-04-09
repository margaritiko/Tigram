//
//  MessageTableViewCell.swift
//  Tigram
//
//  Created by Маргарита Коннова on 24/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
    var messageText: String? {get set}
    func configureMessage(forState state: Bool, withText text: String, withThemeService themeService: ThemeServiceProtocol)
}

class MessageTableViewCell: UITableViewCell, MessageCellConfiguration {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    var messageText: String? {
        didSet {
            self.messageLabel.text = self.messageText
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureMessage(forState state: Bool, withText text: String, withThemeService themeService: ThemeServiceProtocol) {
        self.messageText = text
        messageView.layer.cornerRadius = 15
        if state {
            updateCellWithCurrentTheme(withThemeService: themeService)
        }
    }
    func updateCellWithCurrentTheme(withThemeService themeService: ThemeServiceProtocol) {
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        switch themeName {
        case "light":
            self.backgroundColor = themeService.light
        case "dark":
            self.backgroundColor = themeService.dark
        case "champagne":
            self.backgroundColor = themeService.champagne
        default:
            return
        }
    }
}
