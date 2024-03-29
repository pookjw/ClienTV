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
    
    private let imageArticleBaseListUseCase: ImageArticleBaseListUseCase = ImageArticleBaseListUseCaseImpl()
    private let filterSettingListUseCase: FilterSettingListUseCase = FilterSettingListUseCaseImpl()
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
        
        save()
    }
    
    private init() {
        configureQueue()
        bind()
    }
    
    private func save() {
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
    
    private func fetchImageArticleBaseList(completion: @escaping ([ImageArticleBase]?, Error?) -> Void) {
        imageArticleBaseListUseCase
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
    
    private func bind() {
        filterSettingListUseCase
            .observeFilterSettingList()
            .receive(on: queue)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellableBag)
    }
    
    // MARK: - Helper
    
    private func convertData(from imageArticleBase: ImageArticleBase) -> ImageTopShelfData? {
        // 필터링
        let filterTexts: [String] = (try? filterSettingListUseCase
            .getFilterSettingList()
            .keys
            .map { $0 }) ?? []
        
        for filterText in filterTexts {
            guard !((imageArticleBase.title.localizedCaseInsensitiveContains(filterText)) ||
                (imageArticleBase.nickname.localizedCaseInsensitiveContains(filterText))) else {
                return nil
            }
        }
        
        guard let previewImageURL: URL = imageArticleBase.previewImageURL else {
            return nil
        }
        
        guard let previewBodyAttributedString: NSAttributedString = imageArticleBase.previewBody.convertToAttributedStringFromHTMLWithClear() else{
            return nil
        }
        
        let previewBodyString: String = previewBodyAttributedString.string
        
        return .init(previewImageURL: previewImageURL,
                     title: imageArticleBase.title,
                     previewBody: previewBodyString,
                     nickname: imageArticleBase.nickname,
                     path: imageArticleBase.path)
    }
}
