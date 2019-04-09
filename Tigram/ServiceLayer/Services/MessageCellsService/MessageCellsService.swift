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
    var tableView: UITableView?
    // MARK: ThemesService
    var themesService: ThemeServiceProtocol!

    // MARK: Functions
    init(themesService: ThemeServiceProtocol) {
        self.themesService = themesService
    }
    func reinit(tableView: UITableView) {
        self.tableView = tableView
    }
    func configure(cellWithMessage message: Message?, at indexPath: IndexPath) -> MessageTableViewCell {
        let isIncoming = message?.isIncoming ?? false
        let cell = tableView?.dequeueReusableCell(withIdentifier: isIncoming ? incomingMessageID : sentMessageID, for: indexPath) as? MessageTableViewCell ?? MessageTableViewCell()
        cell.configureMessage(forState: isIncoming, withText: message?.text ?? "", withThemeService: themesService)
        return cell
    }
}
