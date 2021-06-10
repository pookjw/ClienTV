//
//  ImageArticleBaseTVCollectionViewFullScreenCell.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/10/21.
//

import TVUIKit
import Kingfisher

final class ImageArticleBaseTVCollectionViewFullScreenCell: TVCollectionViewFullScreenCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    func configure(_ data: ImageArticleBaseListCellItem.ImageArticleBaseData) {
        previewImageView.image = nil
        previewImageView.kf.indicatorType = .activity
        previewImageView.kf.setImage(with: data.previewImageURL)
    }
}
