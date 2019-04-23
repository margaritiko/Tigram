//
//  IServicesAssembly.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol IServicesAssembly {
    var emblemsEmitterService: EmblemsEmitterServiceProtocol { get }
    var networkService: NetworkServiceProtocol { get }
    var dataService: DataServiceProtocol { get }
    var messageCellsService: MessageCellsServiceProtocol { get }
    var keyboardProfileService: KeyboardServiceProtocol { get }
    var keyboardMessagesService: KeyboardServiceProtocol { get }
    var frcDelegateListConversations: FetchedResultsControllerProtocol { get }
    var frcDelegateConversation: FetchedResultsControllerProtocol { get }
    var userProfileCDService: UserProfileCDServiceProtocol { get }
    var communicatorService: CommunicatorServiceProtocol {get}
    var userService: UserServiceProtocol { get }
    var themeService: ThemeServiceProtocol { get }
    var coreDataManager: CoreDataManagerProtocol { get }
}
