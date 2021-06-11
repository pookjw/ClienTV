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

final class ImageTopShelfSaver {
    static let shared: ImageTopShelfSaver = .init()
    
    private let useCase: ImageArticleBaseListUseCase
    private let userDefaults: UserDefaults = .init(suiteName: "group.com.pookjw.ClienTV") ?? .standard
    private let queue: OperationQueue = .init()
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
        }
    }
    
    private init(useCase: ImageArticleBaseListUseCase = ImageArticleBaseListUseCaseImpl()) {
        self.useCase = useCase
        configureQueue()
    }
    
    private func configureQueue() {
        queue.qualityOfService = .background
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
                    Logger.info("이미지 캐시 저장 완료!")
                }
            } receiveValue: { imageArticleBaseList in
                completion(imageArticleBaseList, nil)
            }
            .store(in: &cancellableBag)
    }
    
    private func saveImageTopShelfObjects(from imageArticleBaseList: [ImageArticleBase]) {
        let objects: [ImageTopShelfObject] = imageArticleBaseList
            .compactMap { [weak self] imageArticleBase in
                return self?.convertObject(from: imageArticleBase)
            }
        
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: objects, requiringSecureCoding: false)
            userDefaults.set(data, forKey: ImageTopShelfConstant.imageTopShelfObjectsDataKey)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    private func saveTimestamp() {
        userDefaults.set(Date(), forKey: ImageTopShelfConstant.timestampKey)
    }
    
    // MARK: - Helper
    
    private func convertObject(from imageArticleBase: ImageArticleBase) -> ImageTopShelfObject? {
        guard let previewImageURL: URL = imageArticleBase.previewImageURL else {
            return nil
        }
        
        guard let previewBodyAttributedString: NSAttributedString = imageArticleBase.previewBody.convertToAttributedStringFromHTML() else{
            return nil
        }
        
        let previewBodyString: String = previewBodyAttributedString.string
        
        return .init(previewImageURL: previewImageURL,
                     category: imageArticleBase.category,
                     title: imageArticleBase.title,
                     previewBody: previewBodyString,
                     timestamp: imageArticleBase.timestamp,
                     nickname: imageArticleBase.nickname,
                     path: imageArticleBase.path)
    }
}
