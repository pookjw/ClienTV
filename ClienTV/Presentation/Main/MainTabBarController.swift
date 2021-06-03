//
//  MainTabBarController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit
import OSLog

final class MainTabBarController: UITabBarController {
    private weak var homeSplitViewController: HomeSplitViewController? = nil
    private weak var settingsViewController: SettingsViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    private func configureViewControllers() {
        let homeSplitViewController: HomeSplitViewController = .init()
        let settingsViewController: SettingsViewController = .init()
        
        self.homeSplitViewController = homeSplitViewController
        self.settingsViewController = settingsViewController
        
        homeSplitViewController.preferredDisplayMode = .oneBesideSecondary
        
        homeSplitViewController.tabBarItem = .init(title: "홈",
                                                   image: UIImage(systemName: "house"),
                                                   tag: 0)
        settingsViewController.tabBarItem = .init(title: "설정",
                                                  image: UIImage(systemName: "gearshape"),
                                                  tag: 1)
        
        homeSplitViewController.loadViewIfNeeded()
        settingsViewController.loadViewIfNeeded()
        
        setViewControllers([homeSplitViewController, settingsViewController], animated: false)
    }
}
