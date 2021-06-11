//
//  MainTabBarController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit
import Combine
import OSLog

final class MainTabBarController: UITabBarController {
    private weak var homeSplitViewController: HomeSplitViewController? = nil
    private weak var settingsViewController: SettingsViewController? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        bind()
    }
    
    private func configureViewControllers() {
        let homeSplitViewController: HomeSplitViewController = .init()
        let settingsViewController: SettingsViewController = .init()
        
        self.homeSplitViewController = homeSplitViewController
        self.settingsViewController = settingsViewController
        
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
    
    private func bind() {
        ShortcutService
            .shared
            .categoryEvent
            .receive(on: OperationQueue.main)
            .sink { [weak self] category in
                switch category {
                case .article(let boardPath, let articlePath):
                    self?.presentArticleViewController(boardPath: boardPath, articlePath: articlePath)
                }
            }
            .store(in: &cancellableBag)
    }
    
    private func presentArticleViewController(boardPath: String, articlePath: String) {
        let articleViewController: ArticleViewController = .loadFromNib()
        articleViewController.loadViewIfNeeded()
        articleViewController.requestArticle(boardPath: boardPath, articlePath: articlePath)
        present(articleViewController, animated: true, completion: nil)
    }
}
