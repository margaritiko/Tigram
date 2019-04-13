//
//  CoreAssembly.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

class CoreAssembly: ICoreAssembly {
    lazy var communicatorStorage: MultipeerCommunicatorProtocol = MultipeerCommunicator()

    lazy var coreDataStorage: CoreDataManagerProtocol = CoreDataManager()

    lazy var requestSender: IRequestSender = RequestSender()
}
