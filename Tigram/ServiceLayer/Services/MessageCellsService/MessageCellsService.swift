//
//  MessageCellsService.swift
//  Tigram
//
//  Created by Маргарита Коннова on 07/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

// MARK: Creates a cell for each table view row
class MessageCellsService: MessageCellsServiceProtocol {
    // MARK: Fields
    let incomingMessageID = "Incoming Message"
    let sentMessageID = "Sent Message"
    let tableView: UITableView!

    // MARK: Functions
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    func configure(cellWithMessage message: Message?, at indexPath: IndexPath) -> MessageTableViewCell {
        let isIncoming = message?.isIncoming ?? false
        let cell = tableView.dequeueReusableCell(withIdentifier: isIncoming ? incomingMessageID : sentMessageID, for: indexPath) as? MessageTableViewCell ?? MessageTableViewCell()
        cell.configureMessage(forState: isIncoming, withText: message?.text ?? "")
        return cell
    }
}
