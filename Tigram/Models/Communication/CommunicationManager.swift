//
//  CommunicationManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 17/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

protocol CommunicationManagerProtocol: class {
    func didUpdateConversations(conversations: [Conversation])
}

class CommunicationManager: NSObject, CommunicatorDelegate {
    var allConversations: [Conversation] = []
    var communicator: MultipeerCommunicator?
    
    // Updates view
    weak var viewDelegate: CommunicationManagerProtocol?
    // Updates data
    var conversationDelegate: ConversationDelegate?
    
    override init() {
        super.init()
        
        // Creates communicator
        communicator = MultipeerCommunicator(delegate: self)
    }
    
    func didFoundUser(userID: String, userName: String?) {
        if let conversation = allConversations.first(where: {$0.userId == userID}) {
            conversation.isInterlocutorOnline = true
        }
        else {
            let conversation = ConversationManager().createNewConversationWith(userName: userName ?? "Name", userID: userID)
            // Adds new conversation to list with all conversations
            allConversations.append(conversation)
        }
        
        viewDelegate?.didUpdateConversations(conversations: allConversations)
        conversationDelegate?.didUserIsOnline(online: true)
    }
    
    func didLostUser(userID: String) {
        if let conversation = allConversations.first(where: {$0.userId == userID}) {
            // Now interlocutor is offline
            conversation.isInterlocutorOnline = false
        }
        
        viewDelegate?.didUpdateConversations(conversations: allConversations)
        conversationDelegate?.didUserIsOnline(online: false)
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        for conversation in allConversations {
            if conversation.userId == fromUser {
                // Adds new message to conversation
                conversation.allMessagesFromCurrentConversation?.append(Message(text: text, isIncoming: true))
                conversation.hasUnreadMessages = true
                conversationDelegate?.didGetMessages(messages: conversation.allMessagesFromCurrentConversation)
            }
        }
        viewDelegate?.didUpdateConversations(conversations: allConversations)
    }
    
    // MARK: Errors
    func failedToStartBrowsingForUsers(error: Error) {
        print("ERROR in \(#function): \(error)")
    }
    
    func failedToStartAdvertising(error: Error) {
        print("ERROR in \(#function): \(error)")
    }
}

