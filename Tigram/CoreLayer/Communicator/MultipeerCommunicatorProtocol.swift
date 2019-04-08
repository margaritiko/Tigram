//
//  MultipeerCommunicatorProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol MultipeerCommunicatorProtocol {
    func sendMessage(string: String, to userID: String, completionHandler:((_ success: Bool, _ error: Error?) -> Void)?)
    var delegate: CommunicatorServiceProtocol? {get set}
    var isOnline: Bool {get set}
}
