//
//  ArticleViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit
import Combine
import OSLog
import Kingfisher
import ClienTVAPI

final class ArticleViewController: UIViewController {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nicknameImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var commentListButton: UIButton!
    
    private var dateFormatter: DateFormatter?
    private var viewModel: ArticleViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        clearContents()
        configureDateFormatter()
        configureViewModel()
    }
    
    func requestArticle(boardPath: String, articlePath: String) {
        clearContents()
        let future: Future<Article, Error> = viewModel.requestArticle(boardPath: boardPath, articlePath: articlePath)
        handleRequestCompletion(future)
    }
    
    private func setAttributes() {
        bodyTextView.isUserInteractionEnabled = true
        bodyTextView.isSelectable = true
        bodyTextView.isScrollEnabled = true
        bodyTextView.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.indirect.rawValue] as [NSNumber]
    }
    
    private func clearContents() {
        categoryLabel.text = nil
        titleLabel.text = nil
        nicknameImageView.kf.cancelDownloadTask()
        nicknameImageView.image = nil
        nicknameLabel.text = nil
        timestampLabel.text = nil
        hitCountLabel.text = nil
        likeCountLabel.text = nil
        bodyTextView.text = nil
        commentListButton.isEnabled = false
        commentListButton.setTitle(nil, for: .normal)
    }
    
    private func configureDateFormatter() {
        let dateFormatter: DateFormatter = .init()
        self.dateFormatter = dateFormatter
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    private func configureViewModel() {
        let viewModel: ArticleViewModel = .init()
        self.viewModel = viewModel
    }
    
    private func handleRequestCompletion(_ future: Future<Article, Error>) {
        future
            .receive(on: OperationQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showErrorAlert(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] article in
                self?.updateContents(article)
            }
            .store(in: &cancellableBag)
    }
    
    private func updateContents(_ article: Article) {
        let articleBase: ArticleBase = article.base
        
        categoryLabel.text = articleBase.category
        titleLabel.text = articleBase.title
        
        if let nicknameImageURL: URL = articleBase.nicknameImageURL {
            nicknameImageView.isHidden = false
            nicknameImageView.image = nil
            nicknameImageView.kf.indicatorType = .activity
            nicknameImageView.kf.setImage(with: nicknameImageURL)
            nicknameLabel.isHidden = true
        } else {
            nicknameImageView.isHidden = true
            nicknameImageView.kf.cancelDownloadTask()
            nicknameImageView.image = nil
            nicknameLabel.isHidden = false
        }
        
        nicknameLabel.text = articleBase.nickname
        
        timestampLabel.text = dateFormatter?.string(from: articleBase.timestamp)
        hitCountLabel.text = String("\(articleBase.hitCount) 조회수")
        likeCountLabel.text = String("\(articleBase.likeCount) 공감수")
        
        if let attributedString: NSMutableAttributedString = article.bodyHTML.convertToAttributedStringFromHTML()?.mutableCopy() as? NSMutableAttributedString {
            let totalRange: NSRange = NSMakeRange(0, attributedString.length)
            attributedString.removeAttribute(NSAttributedString.Key.foregroundColor, range: totalRange)
            attributedString.removeAttribute(NSAttributedString.Key.font, range: totalRange)
            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)], range: totalRange)
            bodyTextView.attributedText = attributedString.copy() as? NSAttributedString
        }
        
        if articleBase.commentCount > 0 {
            commentListButton.isEnabled = true
            commentListButton.setTitle(String("\(articleBase.commentCount)개의 댓글 보기"), for: .normal)
        } else {
            commentListButton.isEnabled = false
            commentListButton.setTitle("댓글 없음", for: .normal)
        }
    }
    
    private func presentCommentListViewController() {
        guard let boardPath: String = viewModel.boardPath,
              let articlePath: String = viewModel.articlePath else {
            Logger.error("boardPath 또는 articlePath이 nil")
            return
        }
        
        let commentListViewController: CommentListViewController = .init()
        commentListViewController.loadViewIfNeeded()
        commentListViewController.requestCommentList(boardPath: boardPath, articlePath: articlePath)
        present(commentListViewController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func pressedCommentListButton(_ sender: UIButton) {
        presentCommentListViewController()
    }
}
