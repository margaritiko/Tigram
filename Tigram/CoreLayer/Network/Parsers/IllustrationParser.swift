//
//  IllustrationParser.swift
//  Tigram
//
//  Created by Маргарита Коннова on 14/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

struct IllustrationModel {
    var illustration: UIImage
}

class IllustrationParser: IParser {
    typealias Model = IllustrationModel
    func parse(data: Data) -> IllustrationModel? {
        guard let image = UIImage(data: data) else {
            print("Image data is incorrect")
            return nil
        }
        return IllustrationModel(illustration: image)
    }
}
