//
//  HeaderLabel.swift
//  Tigram
//
//  Created by Маргарита Коннова on 21/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class HeaderLabel: UILabel {

    // MARK: Fields
    private let onlineColor: UIColor = UIColor(red: 0.20, green: 0.80, blue: 0.20, alpha: 1.0)
    private let offlineColor: UIColor = .black

    // MARK: Properties
    var isInterlocutorOnline: Bool! {
        didSet {
            // Transform and color depends on current isInterlocutorOnline value
            let transform = isInterlocutorOnline ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
            let color = isInterlocutorOnline ? onlineColor : offlineColor

            UIView.transition(with: self, duration: 1.0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                self.textColor = color
                self.transform = transform
            }, completion: nil)
        }
    }

    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
