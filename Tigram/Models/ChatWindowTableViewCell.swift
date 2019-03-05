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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var name: String? {
        didSet {
            self.nameLabel.text = self.name
        }
    }
    var message: String?
    var date: Date? {
        didSet {
            // Converts message's date to string
            dateLabel.text = convertGivenDateToString(self.date!)
        }
    }
    var online: Bool = true {
        didSet {
            // Changes background to light yellow if user online
            if (!self.online) {
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
    
    public func configureChatWindowCellWithData(userName name: String, message: String?, date: Date, isOnline online: Bool, hasUnreadMessages: Bool) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
        
        // Adds user's message
        if let messageDetail = self.message {
            messageLabel.text = messageDetail
            
            // Makes font bold if user hasn't read message yet
            if (self.hasUnreadMessages) {
                messageLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
            }
            else {
                messageLabel.font = UIFont(name:"HelveticaNeue", size: 14.0)
            }
        }
        else {
            messageLabel.text = "No messages yet."
            messageLabel.font = UIFont(name: "Noteworthy", size: 14.0)
        }
    }
    
    func convertGivenDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        if (Calendar.current.compare(Date(), to: date, toGranularity: .day) == .orderedSame) {
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        }
        else {
            dateFormatter.dateFormat = "dd MMM"
        }
        let dayAndMonth = dateFormatter.string(from: date)
        return dayAndMonth
    }
    
    func configureCellWithCurrentThemes(color: String) {
        if (self.online) {
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
