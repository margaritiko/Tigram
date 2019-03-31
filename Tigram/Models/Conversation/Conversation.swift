//
//  Conversation.swift
//  Tigram
//
//  Created by Маргарита Коннова on 17/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

// All necessary information about conversation with user
protocol ConversationProtocol: class {
    // Bool fileds declaration
    var isInterlocutorOnline: Bool {get set}
    var hasUnreadMessages: Bool {get set}

    // Information about messages in conversation declaration
    var message: String? {get set}
    var allMessagesFromCurrentConversation: [Message]? {get set}
    var dateOfLastMessage: Date? {get set}
    // Other data declaration
    var conversationName: String? {get set}
    var userId: String? {get set}
}

public class Conversation: ConversationProtocol {
    // Bool fileds
    var isInterlocutorOnline: Bool
    var hasUnreadMessages: Bool
    // Information about messages in conversation
    var message: String?
    var allMessagesFromCurrentConversation: [Message]?
    var dateOfLastMessage: Date?
    // Other data
    var conversationName: String?
    var userId: String?
    init(userName: String?, userId: String) {
        self.conversationName = userName
        self.userId = userId
        // Init other data with start values
        self.dateOfLastMessage = Date()
        self.message = nil
        self.allMessagesFromCurrentConversation = []
        self.isInterlocutorOnline = true
        self.hasUnreadMessages = true
    }
}
