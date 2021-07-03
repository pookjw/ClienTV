//
//  CommentListViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/7/21.
//

import UIKit
import Combine
import OSLog
import ClienTVAPI

final class CommentListViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<CommentListHeaderItem, CommentListCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<CommentListHeaderItem, CommentListCellItem>
    
    private(set) var boardPath: String?
    private(set) var articlePath: String?
    private let dataSource: DataSource
    private let commentListUseCase: CommentListUseCase = CommentListUseCaseImpl()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    func getHeaderItem(from indexPath: IndexPath) -> CommentListHeaderItem? {
        let snapshot: Snapshot = dataSource.snapshot()
        return snapshot.getHeaderItem(from: indexPath)
    }
    
    func requestCommentList(boardPath: String, articlePath: String) -> Future<Void, Error> {
        self.boardPath = boardPath
        self.articlePath = articlePath
        
        return .init { [weak self] promise in
            guard let self = self else {
                return
            }
            
            let path: String = "\(boardPath)/\(articlePath)"
            
            self.commentListUseCase
                .getCommentList(path: path)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] commentList in
                    self?.updateCommentList(commentList)
                    promise(.success(()))
                }
                .store(in: &self.cancellableBag)
        }
    }
    
    private func updateCommentList(_ commentList: [Comment]) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItems()
        
        let commentCountData: CommentListHeaderItem.CommentCountData = .init(count: commentList.count)
        let commentListHeaderItem: CommentListHeaderItem = .init(dataType: .commentCount(data: commentCountData))
        
        let commentCellItems: [CommentListCellItem] = commentCellItems(from: commentList)
        
        snapshot.appendSections([commentListHeaderItem])
        snapshot.appendItems(commentCellItems, toSection: commentListHeaderItem)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Helper
    private func commentCellItems(from commentList: [Comment]) -> [CommentListCellItem] {
        let cellItems: [CommentListCellItem] = commentList
            .map { comment -> CommentListCellItem.CommentData in
                return .init(isAuthor: comment.isAuthor,
                             isReply: comment.isReply,
                             nickname: comment.nickname,
                             nicknameImageURL: comment.nicknameImageURL,
                             timestamp: comment.timestamp,
                             likeCount: comment.likeCount,
                             bodyImageURL: comment.bodyImageURL,
                             bodyHTML: comment.bodyHTML)
            }
            .map { data -> CommentListCellItem in
                return .init(dataType: .comment(data: data))
            }
        
        return cellItems
    }
}
