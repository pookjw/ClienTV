//
//  HomeSplitViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit

final class HomeSplitViewController: UISplitViewController {
    private struct Const {
        static let imageBoardPath: String = "/service/board/image"
    }
    
    private weak var boardListViewController: BoardListViewController!
    private var articleBaseListViewController: ArticleBaseListViewController!
    private var imageArticleBaseListViewController: ImageArticleBaseListViewController!

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
        let imageArticleBaseListViewController: ImageArticleBaseListViewController = .init()
        
        self.boardListViewController = boardListViewController
        self.articleBaseListViewController = articleBaseListViewController
        self.imageArticleBaseListViewController = imageArticleBaseListViewController
        
        boardListViewController.delegate = self
        
        boardListViewController.loadViewIfNeeded()
        articleBaseListViewController.loadViewIfNeeded()
        imageArticleBaseListViewController.loadViewIfNeeded()
        
        viewControllers = [boardListViewController, articleBaseListViewController]
    }
    
    private func handleBoardPathEvent(_ boardPath: String) {
        switch boardPath {
        case Const.imageBoardPath:
            viewControllers = [boardListViewController, imageArticleBaseListViewController]
            imageArticleBaseListViewController.requestImageArticleBaseList()
        default:
            viewControllers = [boardListViewController, articleBaseListViewController]
            articleBaseListViewController.requestArticleBaseList(with: boardPath)
        }
    }
}

extension HomeSplitViewController: BoardListViewControllerDelegate {
    func boardListViewControllerDidTapCell(_ viewController: BoardListViewController, boardPath: String) {
        handleBoardPathEvent(boardPath)
    }
}
