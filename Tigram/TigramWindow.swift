//
//  TigramWindow.swift
//  Tigram
//
//  Created by Маргарита Коннова on 22/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class TigramWindow: UIWindow {

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(frame: CGRect, emblemsEmitterService: EmblemsEmitterServiceProtocol) {
        super.init(frame: frame)
        self.emblemsEmitterService = emblemsEmitterService
        self.emblemsEmitterService.reinit(window: self)
    }

    // MARK: Fields

    var emblemsEmitterService: EmblemsEmitterServiceProtocol!

    // MARK: Detecting touches

    override func sendEvent(_ event: UIEvent) {
        // Checks if there was any touch
        if event.type != UIEvent.EventType.touches {
            super.sendEvent(event)
            return
        }
        // Gets information about all touches
        guard let touches = event.allTouches else {
            super.sendEvent(event)
            return
        }
        // Looking for each touch from array
        for touch in touches {
            switch touch.phase {
            case .began:
                emblemsEmitterService.beginEmitting(for: touch)
            case .cancelled, .ended:
                emblemsEmitterService.finishEmitting()
            case .moved:
                emblemsEmitterService.updateEmitting(for: touch)
            case .stationary:
                super.sendEvent(event)
                return
            }
        }

        super.sendEvent(event)
    }
}
