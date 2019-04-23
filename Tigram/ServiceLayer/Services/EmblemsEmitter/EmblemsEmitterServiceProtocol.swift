//
//  EmblemsEmitterProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 22/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol EmblemsEmitterServiceProtocol {
    func reinit(window: UIWindow)
    func beginEmitting(for touch: UITouch)
    func finishEmitting()
    func updateEmitting(for touch: UITouch)
}
