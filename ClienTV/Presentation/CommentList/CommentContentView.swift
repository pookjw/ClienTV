//
//  CommentContentView.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/7/21.
//

import UIKit
import OSLog
import Kingfisher

final class CommentContentView: UIView, UIContentView {
    @IBOutlet weak var replyImageView: UIImageView!
    @IBOutlet weak var nicknameImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var bodyImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyLabelHeightLayout: NSLayoutConstraint!
    
    var commentContentConfiguration: CommentConentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            return commentContentConfiguration
        }
        set {
        }
    }
    
    private var dateFormatter: DateFormatter?
    
    static func initFromConfiguration(_ commentContentConfiguration: CommentConentConfiguration) -> CommentContentView {
        let commentView: CommentContentView = .loadFromNib()
        commentView.configure(commentContentConfiguration: commentContentConfiguration)
        return commentView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureDateFormatter()
        clearContents()
    }
    
    private func configure(commentContentConfiguration: CommentConentConfiguration) {
        self.commentContentConfiguration = commentContentConfiguration
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
        backgroundColor = nil
        replyImageView.isHidden = true
        nicknameImageView.image = nil
        nicknameLabel.text = nil
        timestampLabel.text = nil
        likeCountLabel.text = nil
        bodyImageView.image = nil
        bodyLabel.text = nil
    }
    
    private func configureViews() {
        guard let commentContentConfiguration: CommentConentConfiguration = configuration as? CommentConentConfiguration else {
            Logger.error("configuration is not a type of CommentConentConfiguration")
            return
        }
        
        let commentData: CommentListCellItem.CommentData = commentContentConfiguration.commentData
        
        //
        
        let isAuthor: Bool = commentData.isAuthor
        let isReply: Bool = commentData.isReply
        
        backgroundColor = isAuthor ? .orange : nil
        
        if isReply {
            replyImageView.isHidden = false
        } else {
            replyImageView.isHidden = true
            replyImageView.removeHeightConstraint()
        }
        
        //
        
        if let nicknameImageURL: URL = commentData.nicknameImageURL {
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
        
        nicknameLabel.text = commentData.nickname
        
        //
        
        timestampLabel.text = dateFormatter?.string(from: commentData.timestamp)
        
        //
        
        likeCountLabel.text = "\(commentData.likeCount) 공감수"
        
        //
        
        if let bodyImageURL: URL = commentData.bodyImageURL {
            bodyImageView.isHidden = false
            bodyImageView.image = nil
            bodyImageView.kf.indicatorType = .activity
            bodyImageView.kf.setImage(with: bodyImageURL) { [weak self] _ in
                self?.invalidateLayout()
            }
        } else {
            bodyImageView.isHidden = true
            bodyImageView.kf.cancelDownloadTask()
            bodyImageView.image = nil
            bodyImageView.removeHeightConstraint()
        }
        
        //
        
        if let attributedString: NSMutableAttributedString = commentData.bodyHTML.convertToAttributedStringFromHTML()?.mutableCopy() as? NSMutableAttributedString {
            let totalRange: NSRange = NSMakeRange(0, attributedString.length)
            attributedString.removeAttribute(NSAttributedString.Key.foregroundColor, range: totalRange)
            attributedString.removeAttribute(NSAttributedString.Key.font, range: totalRange)
            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)], range: totalRange)
            
            let rect: CGRect = attributedString.boundingRect(with: .init(width: frame.width, height: .greatestFiniteMagnitude),
                                                              options: .usesLineFragmentOrigin,
                                                              context: nil)
            bodyLabel.attributedText = attributedString.copy() as? NSAttributedString
            
            // attributedText의 경우 Label에 frame 크기가 정의되기 까지 시간이 걸리므로, 직접 바로 정의해준다.
            bodyLabelHeightLayout.constant = rect.height
        }
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
