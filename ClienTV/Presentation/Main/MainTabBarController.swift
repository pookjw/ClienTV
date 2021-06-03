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
        
    }
}
