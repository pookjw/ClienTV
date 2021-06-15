//
//  CommentContentView.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/7/21.
//

import UIKit
import OSLog
import Kingfisher
import ClienTVAPI

final class CommentContentView: UIView, UIContentView {
    @IBOutlet weak var replyImageView: UIImageView!
    @IBOutlet weak var nicknameImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var bodyImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyLabelHeightLayout: NSLayoutConstraint!
    
    var configuration: UIContentConfiguration {
        get {
            return commentContentConfiguration
        }
        set {
            commentContentConfiguration = newValue as? CommentContentConfiguration
        }
    }
    
    private var commentContentConfiguration: CommentContentConfiguration!
    private var dateFormatter: ClienDateFormatter = .init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearContents()
    }
    
    func update(commentContentConfiguration: CommentContentConfiguration) {
        self.commentContentConfiguration = commentContentConfiguration
        clearContents()
        configureViews()
    }
    
    func update(isFocused: Bool) {
        if isFocused {
            nicknameLabel.textColor = .black
            bodyLabel.textColor = .black
        } else {
            nicknameLabel.textColor = nil
            bodyLabel.textColor = nil
        }
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
        guard let commentContentConfiguration: CommentContentConfiguration = configuration as? CommentContentConfiguration else {
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
        }
        
        //
        
        if let nicknameImageURL: URL = commentData.nicknameImageURL {
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
        
        nicknameLabel.text = commentData.nickname
        
        //
        
        timestampLabel.text = dateFormatter.string(from: commentData.timestamp)
        
        //
        
        likeCountLabel.text = "\(commentData.likeCount) 공감수"
        
        //
        
        if let bodyImageURL: URL = commentData.bodyImageURL {
            bodyImageView.isHidden = false
            bodyImageView.image = nil
            bodyImageView.kf.indicatorType = .activity
            bodyImageView.kf.setImage(with: bodyImageURL)
        } else {
            bodyImageView.isHidden = true
            bodyImageView.kf.cancelDownloadTask()
            bodyImageView.image = nil
        }
        
        //
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let attributedString: NSMutableAttributedString = commentData.bodyHTML.convertToAttributedStringFromHTML()?.mutableCopy() as? NSMutableAttributedString {
                let totalRange: NSRange = NSMakeRange(0, attributedString.length)
                attributedString.removeAttribute(NSAttributedString.Key.foregroundColor, range: totalRange)
                attributedString.removeAttribute(NSAttributedString.Key.font, range: totalRange)
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)], range: totalRange)
                
                let rect: CGRect = attributedString.boundingRect(with: .init(width: self.frame.width, height: .greatestFiniteMagnitude),
                                                                  options: .usesLineFragmentOrigin,
                                                                  context: nil)
                self.bodyLabel?.attributedText = attributedString.copy() as? NSAttributedString
                
                // attributedText의 경우 Label에 frame 크기가 정의되기 까지 시간이 걸리므로, 직접 바로 정의해준다.
                self.bodyLabelHeightLayout?.constant = ceil(rect.height)
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
}
