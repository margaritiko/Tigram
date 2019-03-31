//
//  ChatWindowTableViewCell.swift
//  Tigram
//
//  Created by Маргарита Коннова on 23/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration: class {
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
}

class ChatWindowTableViewCell: UITableViewCell, ConversationCellConfiguration {
    var conversation: Conversation?
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    var name: String? {
        didSet {
            self.nameLabel.text = self.name
        }
    }
    var message: String?
    var date: Date?
    var online: Bool = true {
        didSet {
            // Changes background to light yellow if user online
            if !self.online {
                self.backgroundColor = UIColor.white
            }
        }
    }
    var hasUnreadMessages: Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCellWithCurrentThemes(color: String) {
        if self.online {
            switch color {
            case "light":
                self.backgroundColor = UIColor(red: 58 / 256.0, green: 123 / 256.0, blue: 240 / 256.0, alpha: 0.25)
            case "dark":
                self.backgroundColor = UIColor(red: 83 / 256.0, green: 103 / 256.0, blue: 120 / 256.0, alpha: 0.5)
            case "champagne":
                self.backgroundColor = UIColor(red: 244 / 256.0, green: 217 / 256.0, blue: 73 / 256.0, alpha: 0.5)
            default:
                self.backgroundColor = UIColor.lightGray
            }
        }
    }
}
