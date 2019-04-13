//
//  IllustrationDetailsRequest.swift
//  Tigram
//
//  Created by Маргарита Коннова on 14/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

class IllustrationDetailsRequest: IRequest {
    var urlRequest: URLRequest?

    init(key: String, page: Int = 1) {
        // Looking for all illustrations
        if let url = URL(string: "https://pixabay.com/api/?key=\(key)&image_type=illustration&page=\(page)") {
            urlRequest = URLRequest(url: url)
            return
        } else {
            print("Incorrect URL")
        }
    }
}
