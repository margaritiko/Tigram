//
//  IPresentationAssembly.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation

protocol IPresentationAssembly {
    // Navigation Controller
    func navigationController() -> UINavigationController
    // Screen with all conversations devided into two sections (Online and History)
    func listWithConversationsViewController() -> ConversationsListViewController
    // Screen with messages with specific user
    func conversationViewController() -> ConversationViewController?
    // Color theme selection screen
    func themesViewController() -> ThemesViewController?
    // Profile screen
    func profileViewController() -> ProfileViewController?
    // Screen where user can find illustration from internet
    func loadingIllustrationsViewController() -> LoadingIllustrationsViewController?
}
