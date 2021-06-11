//
//  ImageTopShelfSaver.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/11/21.
//

import Foundation
import Combine
import OSLog
import ClienTVAPI
import ClienTVTopShelfExtension

final class ImageTopShelfSaver {
    static let shared: ImageTopShelfSaver = .init()
    
    private let useCase: ImageArticleBaseListUseCase
    private let userDefaults: UserDefaults = .init(suiteName: ImageTopShelfConstant.suitName) ?? .standard
    private let queue: OperationQueue = .init()
    private let encoder: JSONEncoder = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    private var shouldSave: Bool {
        guard let prevTimestamp: Date = userDefaults.object(forKey: ImageTopShelfConstant.timestampKey) as? Date else {
            return true
        }
        
        let shouldSave: Bool = (prevTimestamp + ImageTopShelfConstant.saveThrottleInterval) <= Date()
        return shouldSave
    }
    
    //
    
    func saveIfNeeded() {
        guard shouldSave else {
            Logger.info("throttle")
            return
        }
        
        fetchImageArticleBaseList { [weak self] (imageArticleBaseList, error) in
            if let error: Error = error {
                Logger.error(error.localizedDescription)
                return
            }
            
            guard let imageArticleBaseList: [ImageArticleBase] = imageArticleBaseList else {
                Logger.error("imageArticleBaseList is nil!")
                return
            }
            
            self?.saveImageTopShelfObjects(from: imageArticleBaseList)
            self?.saveTimestamp()
            Logger.info("사진게시판 캐시 저장 완료!")
        }
    }
    
    private init(useCase: ImageArticleBaseListUseCase = ImageArticleBaseListUseCaseImpl()) {
        self.useCase = useCase
        configureQueue()
    }
    
    private func fetchImageArticleBaseList(completion: @escaping ([ImageArticleBase]?, Error?) -> Void) {
        useCase
            .getImageArticleBaseList(page: 0)
            .receive(on: queue)
            .sink { result in
                switch result {
                case .failure(let error):
                    completion(nil, error)
                case .finished:
                    break
                }
            } receiveValue: { imageArticleBaseList in
                completion(imageArticleBaseList, nil)
            }
            .store(in: &cancellableBag)
    }
    
    private func saveImageTopShelfObjects(from imageArticleBaseList: [ImageArticleBase]) {
        let datas: [ImageTopShelfData] = imageArticleBaseList
            .compactMap { [weak self] imageArticleBase in
                return self?.convertData(from: imageArticleBase)
            }
        
        do {
            let jsonData: Data = try encoder.encode(datas)
            userDefaults.set(jsonData, forKey: ImageTopShelfConstant.imageTopShelfDatasKey)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    private func saveTimestamp() {
        userDefaults.set(Date(), forKey: ImageTopShelfConstant.timestampKey)
    }
    
    private func configureQueue() {
        queue.qualityOfService = .background
    }
    
    // MARK: - Helper
    
    private func convertData(from imageArticleBase: ImageArticleBase) -> ImageTopShelfData? {
        guard let previewImageURL: URL = imageArticleBase.previewImageURL else {
            return nil
        }
        
        guard let previewBodyAttributedString: NSAttributedString = imageArticleBase.previewBody.convertToAttributedStringFromHTML() else{
            return nil
        }
        
        let previewBodyString: String = previewBodyAttributedString.string
        
        return .init(previewImageURL: previewImageURL,
                     title: imageArticleBase.title,
                     previewBody: previewBodyString,
                     timestamp: imageArticleBase.timestamp,
                     nickname: imageArticleBase.nickname,
                     path: imageArticleBase.path)
    }
}
