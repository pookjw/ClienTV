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
            return articleBaseContentConfiguration!
        }
        set {
        }
    }
    
    private var dateFormatter: DateFormatter? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureDateFormatter()
    }
    
    func configure(articleBaseContentConfiguration: ArticleBaseContentConfiguration) {
        self.articleBaseContentConfiguration = articleBaseContentConfiguration
        configureViews()
    }
    
    private func configureDateFormatter() {
        let dateFormatter: DateFormatter = .init()
        self.dateFormatter = dateFormatter
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    private func configureViews() {
        guard let articleBaseContentConfiguration: ArticleBaseContentConfiguration = configuration as? ArticleBaseContentConfiguration else {
            Logger.error("configuration is not a type of ArticleBaseContentConfiguration")
            return
        }
        
        let articleBaseData: ArticleBaseListCellItem.ArticleBaseData = articleBaseContentConfiguration.articleBaseData
        
        titleLabel.text = articleBaseData.title
        
        if let nicknameImageURL: URL = articleBaseData.nicknameImageURL {
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
        
        nicknameLabel.text = articleBaseData.nickname
//        print("hi!!! \(dateFormatter?.string(from: articleBaseData.timestamp))")
        timestampLabel.text = dateFormatter?.string(from: articleBaseData.timestamp)
        hitCountLabel.text = String("\(articleBaseData.hitCount) 조회수")
        commentCountLabel.text = String(articleBaseData.commentCount)
        likeCountLabel.text = String(articleBaseData.likeCount)
    }
}
