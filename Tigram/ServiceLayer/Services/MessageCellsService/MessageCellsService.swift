//
//  MessageCellsService.swift
//  Tigram
//
//  Created by Маргарита Коннова on 07/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

// Creates a cell for each table view row
class MessageCellsService: MessageCellsServiceProtocol {
    // MARK: Fields
    let incomingMessageID = "Incoming Message"
    let sentMessageID = "Sent Message"
    var tableView: UITableView?
    var themesService: ThemeServiceProtocol!

    // MARK: Life Cycle

    init(themesService: ThemeServiceProtocol) {
        self.themesService = themesService
    }

    // MARK: Other methods

    func reinit(tableView: UITableView) {
        self.tableView = tableView
    }

    func configure(cellWithMessage message: Message?, at indexPath: IndexPath) -> MessageTableViewCell {
        let isIncoming = message?.isIncoming ?? false
        let cell = tableView?.dequeueReusableCell(withIdentifier: isIncoming ? incomingMessageID : sentMessageID, for: indexPath) as? MessageTableViewCell ?? MessageTableViewCell()
        cell.configureMessage(forState: isIncoming, withText: message?.text ?? "", withThemeService: themesService)
        if !isIncoming {
            cell.viewWithTag(1)?.backgroundColor = themesService.getCurrentColor()
        }
        return cell
    }
}
