//
//  IParser.swift
//  Tigram
//
//  Created by Маргарита Коннова on 14/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}
