//
//  MessageCellsService.swift
//  Tigram
//
//  Created by Маргарита Коннова on 07/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

protocol MessageCellsServiceProtocol {
    func configure(cellWithMessage message: Message?, at indexPath: IndexPath) -> MessageTableViewCell
}
