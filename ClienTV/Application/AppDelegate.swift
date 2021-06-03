//
//  AppDelegate.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/2/21.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureWindow()
        return true
    }
    
    private func configureWindow() {
        let window: UIWindow = .init()
        let vc: HomeTabBarController = .init()
        self.window = window
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}

