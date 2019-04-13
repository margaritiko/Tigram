//
//  IllustrationDetailsParser.swift
//  Tigram
//
//  Created by Маргарита Коннова on 14/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import SwiftyJSON

struct IllustrationDetailsModel {
    let illustrationUrl: URL
}

class IllustrationDetailsParser: IParser {
    typealias Model = [IllustrationDetailsModel]
    func parse(data: Data) -> [IllustrationDetailsModel]? {
        do {
            // Converts to JSON
            let json = try JSON(data: data)
            guard let elements = json["hits"].array else {
                return []
            }
            // Creates an empty array for IllustrationDetailsModel objects
            var models: [IllustrationDetailsModel] = []
            for element in elements {
                if let illustrationUrl = element["webformatURL"].url {
                    models.append(IllustrationDetailsModel(illustrationUrl: illustrationUrl))
                }
            }
            return models
        } catch {
            return []
        }
    }
}
