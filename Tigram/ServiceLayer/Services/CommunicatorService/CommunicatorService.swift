//
//  CommunicationManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 17/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class CommunicatorService: NSObject, CommunicatorServiceProtocol {
    var communicator: MultipeerCommunicatorProtocol!
    var coreDataManager: CoreDataManagerProtocol!
    // Updates data
    weak var conversationDelegate: ConversationDelegate?
    init(multipeerCommunicator: MultipeerCommunicatorProtocol, manager: CoreDataManagerProtocol) {
        super.init()
        self.coreDataManager = manager
        // Creates communicator
        multipeerCommunicator.reinit(delegate: self)
        self.communicator = multipeerCommunicator
    }
    func didFoundUser(userID: String, userName: String?) {
        guard let saveContext = coreDataManager.getSaveContext(),
            let user = ChatUser.findOrInsertUser(in: saveContext, userId: userID, with: coreDataManager) else {
                assert(false, "Cannot find or create such user")
        }
        user.name = userName

        let conversation = Conversation.findOrInsertConversation(inContext: saveContext, forUserWithId: userID)
        conversation?.user = user
        conversation?.conversationName = userName
        conversation?.isInterlocutorOnline = true
        conversation?.hasUnreadMessages = conversation?.hasUnreadMessages ?? false
        coreDataManager.performSave(context: saveContext, completionHandler: nil)

        conversationDelegate?.didUserIsOnline(online: true)
    }
    func didLostUser(userID: String) {
        guard let saveContext = coreDataManager.getSaveContext() else {
            fatalError("Save context is nil")
        }
        let conversation = Conversation.findOrInsertConversation(inContext: saveContext, forUserWithId: userID)
        conversation?.isInterlocutorOnline = false
        coreDataManager.performSave(context: saveContext, completionHandler: nil)

        conversationDelegate?.didUserIsOnline(online: false)
    }

    func haveSendMessage(for userId: String, withText text: String, completion: ((Bool, Error?) -> Void)?) {
        communicator?.sendMessage(string: text, to: userId, completionHandler: { (success, error) in
            if success {
                guard let context = self.coreDataManager.getSaveContext(), let conversation = Conversation.findOrInsertConversation(inContext: context, forUserWithId: userId) else {
                    assert(false, "Cannot send a message")
                    return
                }
                let message = Message.insertMessage(with: self.coreDataManager)
                message?.conversation = conversation
                message?.text = text
                message?.isIncoming = false
                message?.date = Date() as NSDate
                conversation.lastMessage = message
                self.coreDataManager.performSave(context: context, completionHandler: nil)
            }
            DispatchQueue.main.async {
                completion?(success, error)
            }
        })
    }

    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        guard let saveContext = coreDataManager.getSaveContext(), let conversation = Conversation.findOrInsertConversation(inContext: saveContext, forUserWithId: fromUser) else {
            assert(false, "Cannot receive messages")
        }
        let message = Message.insertMessage(with: coreDataManager)
        message?.conversation = conversation
        message?.text = text
        message?.date = Date() as NSDate
        message?.isIncoming = true
        conversation.hasUnreadMessages = true
        conversation.lastMessage = message
        coreDataManager.performSave(context: saveContext, completionHandler: nil)
    }
    func readAllNewMessages(with userId: String) {
        guard let saveContext = coreDataManager.getSaveContext(), let conversation = Conversation.findOrInsertConversation(inContext: saveContext, forUserWithId: userId) else {
            assert(false, "Cannot read messages")
        }
        conversation.hasUnreadMessages = false
        coreDataManager.performSave(context: saveContext, completionHandler: nil)
    }
    // MARK: Errors
    func failedToStartBrowsingForUsers(error: Error) {
        print("ERROR in \(#function): \(error)")
    }
    func failedToStartAdvertising(error: Error) {
        print("ERROR in \(#function): \(error)")
    }
}
