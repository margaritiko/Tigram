//
//  CommunicationDelegate.swift
//  Tigram
//
//  Created by Маргарита Коннова on 17/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
protocol CommunicatorServiceProtocol: class {
    var conversationDelegate: ConversationDelegate? { get set }
    // MARK: Looking for users
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    // MARK: Some errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    // MARK: Check for getting messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
    func readAllNewMessages(with userId: String)
    func haveSendMessage(for userId: String, withText text: String, completion: ((Bool, Error?) -> Void)?)
}
