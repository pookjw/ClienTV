//
//  ArticleBaseContentView.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit
import OSLog
import Kingfisher

final class ArticleBaseContentView: UIView, UIContentView {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nicknameImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var articleBaseContentConfiguration: ArticleBaseContentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            return articleBaseContentConfiguration
        }
        set {
            articleBaseContentConfiguration = newValue as? ArticleBaseContentConfiguration
        }
    }
    
    private var dateFormatter: DateFormatter?
    
    static func initFromConfiguration(_ articleBaseContentConfiguration: ArticleBaseContentConfiguration) -> ArticleBaseContentView {
        let contentView: ArticleBaseContentView = .loadFromNib()
        contentView.configure(articleBaseContentConfiguration)
        return contentView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureDateFormatter()
        clearContents()
    }
    
    private func configure(_ articleBaseContentConfiguration: ArticleBaseContentConfiguration) {
        self.articleBaseContentConfiguration = articleBaseContentConfiguration
        clearContents()
        configureViews()
    }
    
    private func configureDateFormatter() {
        let dateFormatter: DateFormatter = .init()
        self.dateFormatter = dateFormatter
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    private func clearContents() {
        categoryLabel.text = nil
        titleLabel.text = nil
        nicknameImageView.image = nil
        nicknameLabel.text = nil
        timestampLabel.text = nil
        hitCountLabel.text = nil
        commentCountLabel.text = nil
        likeCountLabel.text = nil
    }
    
    private func configureViews() {
        guard let articleBaseContentConfiguration: ArticleBaseContentConfiguration = configuration as? ArticleBaseContentConfiguration else {
            Logger.error("configuration is not a type of ArticleBaseContentConfiguration")
            return
        }
        
        let articleBaseData: ArticleBaseListCellItem.ArticleBaseData = articleBaseContentConfiguration.articleBaseData
        
        //
        
        if let category: String = articleBaseData.category {
            categoryLabel.isHidden = false
            categoryLabel.text = category
        } else {
            categoryLabel.isHidden = true
            categoryLabel.text = nil
        }
        
        titleLabel.text = articleBaseData.title
        
        if let nicknameImageURL: URL = articleBaseData.nicknameImageURL {
            nicknameImageView.isHidden = false
            nicknameImageView.image = nil
            nicknameImageView.kf.indicatorType = .activity
            nicknameImageView.kf.setImage(with: nicknameImageURL) { [weak self] _ in
                self?.invalidateLayout()
            }
            nicknameLabel.isHidden = true
        } else {
            nicknameImageView.isHidden = true
            nicknameImageView.kf.cancelDownloadTask()
            nicknameImageView.image = nil
            
            // UIStackView의 버그때문인지, height가 0으로 되어 버려서 Label들이 싹다 안 보이는 문제가 있다. 따라서 height를 0으로 맞춰주는건 꺼버린다.
            nicknameImageView.removeHeightConstraint()
            
            nicknameLabel.isHidden = false
        }
        
        nicknameLabel.text = articleBaseData.nickname
        timestampLabel.text = dateFormatter?.string(from: articleBaseData.timestamp)
        hitCountLabel.text = String("\(articleBaseData.hitCount) 조회수")
        commentCountLabel.text = String(articleBaseData.commentCount)
        likeCountLabel.text = String(articleBaseData.likeCount)
    }
    
    private func getCollectionView() -> UICollectionView? {
        guard let collectionView: UICollectionView = superview?.superview as? UICollectionView else {
            return nil
        }
        return collectionView
    }
    
    private func invalidateLayout() {
        getCollectionView()?.collectionViewLayout.invalidateLayout()
    }
}
