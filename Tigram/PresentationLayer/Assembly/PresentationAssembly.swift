//
//  PresentationAssembly.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit

class PresentationAssembly: IPresentationAssembly {

    private let serviceAssembly: IServicesAssembly

    init(serviceAssembly: IServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }

    func navigationController() -> UINavigationController {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "NavigationVC") as? UINavigationController
        guard var childVC = navigationController?.viewControllers.first as? ConversationsListViewController else {
            return navigationController ?? UINavigationController()
        }
        childVC = listWithConversationsViewController()
        navigationController?.viewControllers = [childVC]
        return navigationController ?? UINavigationController()
    }

    func listWithConversationsViewController() -> ConversationsListViewController {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ConversationsListVC") as? ConversationsListViewController
        viewController?.reinit(communicator: serviceAssembly.communicatorService, manager: serviceAssembly.coreDataManager, frcDelegate: serviceAssembly.frcDelegateListConversations, themeService: serviceAssembly.themeService, presentationAssembly: self)
        return viewController ?? ConversationsListViewController()
    }

    func conversationViewController() -> ConversationViewController? {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationViewController
        viewController?.reinit(mcService: serviceAssembly.messageCellsService, keyboardService: serviceAssembly.keyboardMessagesService, coreDataManager: serviceAssembly.coreDataManager, frcDelegate: serviceAssembly.frcDelegateConversation)
        return viewController
    }

    func themesViewController() -> ThemesViewController? {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ThemesVC") as? ThemesViewController
        viewController?.reinit(themesService: serviceAssembly.themeService)
        return viewController
    }

    func profileViewController() -> ProfileViewController? {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileViewController
        viewController?.reinit(userProfileCDService: serviceAssembly.userProfileCDService, keyboardService: serviceAssembly.keyboardProfileService, presentationAssembly: self)
        return viewController
    }

    func loadingIllustrationsViewController() -> LoadingIllustrationsViewController? {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoadingVC") as? LoadingIllustrationsViewController
        viewController?.reinit(networkService: serviceAssembly.networkService)
        return viewController
    }
}
