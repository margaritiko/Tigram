//
//  EmblemsEmitter.swift
//  Tigram
//
//  Created by Маргарита Коннова on 22/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

class EmblemsEmitterService: EmblemsEmitterServiceProtocol {

    // MARK: Fields
    var window: UIWindow!
    lazy var emitterLayer: CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterShape = CAEmitterLayerEmitterShape.circle
        emitterLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        emitterLayer.emitterCells = [createEmblem()]
        emitterLayer.birthRate = 0
        return emitterLayer
    }()

    // MARK: Methods

    func reinit(window: UIWindow) {
        self.window = window
        self.window.layer.addSublayer(emitterLayer)
    }

    func beginEmitting(for touch: UITouch) {
        emitterLayer.birthRate = 2
        // Update the location of emblems on the screen
        updateEmitting(for: touch)
    }

    func finishEmitting() {
        emitterLayer.birthRate = 0
    }

    func updateEmitting(for touch: UITouch) {
        let location = touch.location(in: window)
        emitterLayer.emitterPosition = location
    }

    private func createEmblem() -> CAEmitterCell {
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "Emblem")?.cgImage
        emitterCell.scale = 0.05
        emitterCell.scaleRange = 0.03
        emitterCell.emissionRange = .pi / 2
        emitterCell.alphaSpeed = -0.75
        emitterCell.lifetime = 1
        emitterCell.birthRate = 5
        emitterCell.velocity = 20
        emitterCell.velocityRange = 40
        emitterCell.emissionLatitude = .pi / 2
        emitterCell.emissionLongitude = .pi / 2
        emitterCell.yAcceleration = 30
        emitterCell.xAcceleration = 5
        emitterCell.spin = .pi
        emitterCell.spinRange = 1.0
        return emitterCell
    }
}
