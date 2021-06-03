//
//  HomeSplitViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit

class HomeSplitViewController: UISplitViewController {
    private weak var boardListViewController: BoardListViewController? = nil
    private weak var articleBaseListViewController: ArticleBaseListViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }

    private func configureViewControllers() {
        let boardListViewController: BoardListViewController = .init()
        let articleBaseListViewController: ArticleBaseListViewController = .init()
        
        self.boardListViewController = boardListViewController
        self.articleBaseListViewController = articleBaseListViewController
        
        boardListViewController.loadViewIfNeeded()
        articleBaseListViewController.loadViewIfNeeded()
        
        viewControllers = [boardListViewController, articleBaseListViewController]
    }

}
