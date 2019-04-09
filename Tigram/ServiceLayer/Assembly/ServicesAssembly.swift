//
//  ServicesAssembly.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import CoreData

class ServicesAssembly: IServicesAssembly {

    private let coreAssembly: ICoreAssembly

    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
    }

    lazy var dataService: DataServiceProtocol = GCDDataService()

    lazy var messageCellsService: MessageCellsServiceProtocol = MessageCellsService(themesService: self.themeService)

    lazy var keyboardProfileService: KeyboardServiceProtocol = KeyboardProfileService()

    lazy var keyboardMessagesService: KeyboardServiceProtocol = KeyboardMessagesService()

    lazy var frcDelegate: NSFetchedResultsControllerDelegate = FRCDelegate()

    lazy var userProfileCDService: UserProfileCDServiceProtocol = UserProfileCDService(manager: coreAssembly.coreDataStorage)

    lazy var communicatorService: CommunicatorServiceProtocol = CommunicatorService(manager: coreAssembly.coreDataStorage, communicator: coreAssembly.communicatorStorage)

    lazy var userService: UserServiceProtocol = UserService()

    lazy var themeService: ThemeServiceProtocol = ThemeService()

    lazy var coreDataManager: CoreDataManagerProtocol = coreAssembly.coreDataStorage
}
