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
        if let launchOptions: [UIApplication.LaunchOptionsKey: Any] = launchOptions {
            handleLaunchOptions(launchOptions)
        }
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ShortcutService.shared.handle(for: url)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        saveImageTopShelf()
    }
    
    private func configureWindow() {
        let window: UIWindow = .init()
        let vc: MainTabBarController = .init()
        self.window = window
        vc.loadViewIfNeeded()
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    private func handleLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]) {
        if let url: URL = launchOptions[.url] as? URL {
            ShortcutService.shared.handle(for: url)
        }
    }
    
    private func saveImageTopShelf() {
        ImageTopShelfSaver.shared.saveIfNeeded()
    }
}

