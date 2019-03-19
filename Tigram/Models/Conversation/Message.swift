//
//  Message.swift
//  Tigram
//
//  Created by Маргарита Коннова on 17/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

protocol MessageProtocol: class {
    var messageText: String? {get set}
    var isIncoming: Bool {get set}
    var messageID: String? {get set}
}

class Message: MessageProtocol {
    var messageID: String?
    var messageText: String?
    var isIncoming: Bool
    var date: Date?
    
    init(text: String?, isIncoming: Bool) {
        self.messageText = text
        self.isIncoming = isIncoming
        
        // Start values for fields
        self.messageID = nil
        self.date = Date()
    }
}
