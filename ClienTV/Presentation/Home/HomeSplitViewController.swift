//
//  HomeSplitViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit

final class HomeSplitViewController: UISplitViewController {
    private weak var boardListViewController: BoardListViewController? = nil
    private weak var articleBaseListViewController: ArticleBaseListViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureViewControllers()
    }
    
    private func setAttributes() {
        preferredDisplayMode = .oneBesideSecondary
    }

    private func configureViewControllers() {
        let boardListViewController: BoardListViewController = .init()
        let articleBaseListViewController: ArticleBaseListViewController = .init()
        
        self.boardListViewController = boardListViewController
        self.articleBaseListViewController = articleBaseListViewController
        
        boardListViewController.delegate = self
        
        boardListViewController.loadViewIfNeeded()
        articleBaseListViewController.loadViewIfNeeded()
        
        viewControllers = [boardListViewController, articleBaseListViewController]
    }
}

extension HomeSplitViewController: BoardListViewControllerDelegate {
    func boardListViewControllerDidTapCell(_ viewController: BoardListViewController, boardPath: String) {
        articleBaseListViewController?.requestArticleBaseList(with: boardPath)
    }
}
