//
//  ICoreAssembly.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol ICoreAssembly {
    var communicatorStorage: MultipeerCommunicatorProtocol { get }
    var coreDataStorage: CoreDataManagerProtocol { get }
}
