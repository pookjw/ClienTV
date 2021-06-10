//
//  ImageArticleBaseCollectoinViewCell.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/10/21.
//

import TVUIKit
import Kingfisher
import SnapKit

final class ImageArticleBaseCollectoinViewCell: TVCollectionViewFullScreenCell {
    
    private weak var previewImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurePreviewImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ data: ImageArticleBaseListCellItem.ImageArticleBaseData) {
        previewImageView.image = nil
        previewImageView.kf.indicatorType = .activity
        previewImageView.kf.setImage(with: data.previewImageURL)
    }
    
    private func configurePreviewImageView() {
        let previewImageView: UIImageView = .init()
        self.previewImageView = previewImageView
        
        addSubview(previewImageView)
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        previewImageView.adjustsImageWhenAncestorFocused = true
    }
}
