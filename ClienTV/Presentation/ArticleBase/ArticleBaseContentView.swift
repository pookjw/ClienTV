//
//  ArticleBaseContentView.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit
import OSLog
import Kingfisher
import ClienTVAPI

final class ArticleBaseContentView: UIView, UIContentView {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nicknameImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var tileLabelLeadingLayout: NSLayoutConstraint!
    @IBOutlet var timestampLabelTextLeadingLayout: NSLayoutConstraint!
    @IBOutlet var timpstampLabelImageLeadingLayout: NSLayoutConstraint!
    @IBOutlet var timestampLabelTextBottomLayout: NSLayoutConstraint!
    @IBOutlet var timestampLabelImageBottomLayout: NSLayoutConstraint!
    
    var configuration: UIContentConfiguration {
        get {
            return articleBaseContentConfiguration
        }
        set {
            articleBaseContentConfiguration = newValue as? ArticleBaseContentConfiguration
        }
    }
    
    private var articleBaseContentConfiguration: ArticleBaseContentConfiguration!
    private var dateFormatter: ClienDateFormatter = .init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearContents()
    }
    
    func update(_ articleBaseContentConfiguration: ArticleBaseContentConfiguration) {
        self.articleBaseContentConfiguration = articleBaseContentConfiguration
        clearContents()
        configureViews()
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
            categoryLabel.text = category
            tileLabelLeadingLayout.constant = 10
        } else {
            categoryLabel.text = nil
            tileLabelLeadingLayout.constant = 0
        }
        
        titleLabel.text = articleBaseData.title
        
        if let nicknameImageURL: URL = articleBaseData.nicknameImageURL {
            nicknameImageView.isHidden = false
            nicknameImageView.image = nil
            nicknameImageView.kf.indicatorType = .activity
            nicknameImageView.kf.setImage(with: nicknameImageURL) { [weak self] _ in
                self?.layoutSubviews()
            }
            nicknameLabel.isHidden = true
            timestampLabelTextLeadingLayout.isActive = false
            timpstampLabelImageLeadingLayout.isActive = true
            timestampLabelTextBottomLayout.isActive = false
            timestampLabelImageBottomLayout.isActive = true
        } else {
            nicknameImageView.isHidden = true
            nicknameImageView.kf.cancelDownloadTask()
            nicknameImageView.image = nil
            nicknameLabel.isHidden = false
            timestampLabelTextLeadingLayout.isActive = true
            timpstampLabelImageLeadingLayout.isActive = false
            timestampLabelTextBottomLayout.isActive = true
            timestampLabelImageBottomLayout.isActive = false
        }
        
        nicknameLabel.text = articleBaseData.nickname
        timestampLabel.text = dateFormatter.string(from: articleBaseData.timestamp)
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
