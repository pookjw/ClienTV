//
//  ImageTopShelfData+Helper.swift
//  ClienTVTopShelfExtension
//
//  Created by Jinwoo Kim on 6/11/21.
//

import TVServices

extension ImageTopShelfData {
    func makeCarouselItem() -> TVTopShelfCarouselItem {
        let item: TVTopShelfCarouselItem = .init(identifier: path)

        item.contextTitle = "클리앙 사진게시판"
        item.title = title
        item.summary = previewBody
        item.genre = nil
        item.creationDate = timestamp
        item.previewVideoURL = nil
        item.mediaOptions = []
        item.namedAttributes = [
            .init(name: "글쓴이", values: [nickname])
        ]
        item.setImageURL(previewImageURL, for: .screenScale1x)
        item.setImageURL(previewImageURL, for: .screenScale2x)

        item.playAction = nil
        item.displayAction = nil

        return item
    }
}
