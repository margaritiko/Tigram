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
    func configureMessage(forState state: Bool, withText text: String)
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

    func configureMessage(forState state: Bool, withText text: String) {
        self.messageText = text
        messageView.layer.cornerRadius = 15
        if state {
            updateCellWithCurrentTheme()
        }
    }
    func updateCellWithCurrentTheme() {
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        switch themeName {
        case "light":
            self.backgroundColor = ThemeService().light
        case "dark":
            self.backgroundColor = ThemeService().dark
        case "champagne":
            self.backgroundColor = ThemeService().champagne
        default:
            return
        }
    }
}
