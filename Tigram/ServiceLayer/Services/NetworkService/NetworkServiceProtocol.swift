//
//  NetworkServiceProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 14/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol NetworkServiceProtocol {
    func numberOfIllustrations() -> Int
    func loadIllustrationsDetails(completionHandler: @escaping () -> Void)
    func loadIllustration(for indexPath: Int, completionHandler: @escaping (_ image: IllustrationParser.Model) -> Void)
}
