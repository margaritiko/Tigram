//
//  NetworkService.swift
//  Tigram
//
//  Created by Маргарита Коннова on 14/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

class NetworkService: NetworkServiceProtocol {

    // MARK: Life Cycle
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }

    // MARK: Private fields
    let requestSender: IRequestSender
    private var pageToSearchIn = 1
    private var urls = [Int: URL]()

    // MARK: NetworkServiceProtocol
    func numberOfIllustrations() -> Int {
        return urls.count
    }

    func loadIllustrationsDetails(completionHandler: @escaping () -> Void) {
        if urls.isEmpty {
            pageToSearchIn = 1
        }
        let config = RequestsFactory.IllustrationsFromPixabayRequests.illustrationDetailsConfig(onPage: pageToSearchIn)
        requestSender.send(config: config) { [weak self] (result) in
            switch result {
            case .success(let imageInfos):
                guard let self = self else {
                    return
                }
                let currentOffset = self.urls.count
                DispatchQueue.main.sync {
                    for (index, imageInfo) in imageInfos.enumerated() {
                        self.urls[index + currentOffset] = imageInfo.illustrationUrl
                    }
                }
                self.pageToSearchIn += 1
                completionHandler()
            case .error(let description):
                print(description)
            }
        }
    }

    func loadIllustration(for indexPath: Int, completionHandler: @escaping (_ image: IllustrationParser.Model) -> Void) {
        guard let url = urls[indexPath] else { return }
        let imageConfig = RequestsFactory.IllustrationsFromPixabayRequests.illustrationConfig(url: url)
        requestSender.send(config: imageConfig, completionHandler: { [weak self] (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.sync {
                    guard url == self?.urls[indexPath] else {
                        return
                    }
                }
                completionHandler(image)
            case .error(let description):
                print(description)
            }
        })
    }
}
