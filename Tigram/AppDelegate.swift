//
//  AppDelegate.swift
//  Tigram
//
//  Created by Маргарита Коннова on 10/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

// MARK: Logs available only in Debug mode
// Change to Release in Product -> Scheme -> Edit scheme... -> Build Configuration and logs will be disabled
#if !DEBUG
func print(_ string: String) {}
#endif

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let rootAssembly = RootAssembly()

    // MARK: Application lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Custom window for detecting touches everywhere
        self.window = TigramWindow(frame: UIScreen.main.bounds, emblemsEmitterService: rootAssembly.presentationAssembly.getServiceAssembly().emblemsEmitterService)
        let controller = rootAssembly.presentationAssembly.navigationController()
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
