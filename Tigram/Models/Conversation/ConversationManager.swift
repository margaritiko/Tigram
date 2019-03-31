//
//  ConversationManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 17/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class ConversationManager: NSObject {
    // Creates new conversation with given user's name and id
    func createNewConversationWith(userName: String, userID: String) -> Conversation {
        let conversation = Conversation(userName: userName, userId: userID)
        return conversation
    }
}
