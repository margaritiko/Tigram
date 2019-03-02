//
//  MessageTableViewCell.swift
//  Tigram
//
//  Created by Маргарита Коннова on 24/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
    var Text: String? {get set}
}

class MessageTableViewCell: UITableViewCell, MessageCellConfiguration {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    var Text: String? {
        didSet {
            self.messageLabel.text = self.Text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureMessage(withText text: String) {
        self.Text = text
        messageView.layer.cornerRadius = 15
    }
}
