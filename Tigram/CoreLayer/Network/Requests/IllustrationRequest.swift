//
//  IllustrationRequest.swift
//  Tigram
//
//  Created by Маргарита Коннова on 14/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

class IllustrationRequest: IRequest {
    var urlRequest: URLRequest?

    init(url: URL) {
        // Creates a request with given url
        urlRequest = URLRequest(url: url)
    }
}
