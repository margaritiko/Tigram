//
//  RequestsFactory.swift
//  Tigram
//
//  Created by Маргарита Коннова on 13/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
struct RequestsFactory {

    struct IllustrationsFromPixabayRequests {

        static func illustrationConfig(url: URL) -> RequestConfig<IllustrationParser> {
            return RequestConfig(request: IllustrationRequest(url: url), parser: IllustrationParser())
        }

        static func illustrationDetailsConfig(onPage page: Int = 1) -> RequestConfigAllDetails<IllustrationDetailsModel, IllustrationDetailsParser> {
            // Key from Pixabay website
            let key = "2023606-d3ac7ac6e6b19e42498926eb9"
            return RequestConfigAllDetails(
                request: IllustrationDetailsRequest(key: key, page: page),
                parser: IllustrationDetailsParser()
            )
        }
    }

}
