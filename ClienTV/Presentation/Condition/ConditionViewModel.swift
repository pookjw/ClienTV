//
//  ConditionViewModel.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/17/21.
//

import Foundation
import Combine
import ClienTVAPI

final class ConditionViewModel {
    private let useCase: ConditionUseCase
    private let settingService: SettingsService = .shared
    private let queue: OperationQueue = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init(useCase: ConditionUseCase = ConditionUseCaseImpl()) {
        self.useCase = useCase
        configureQueue()
    }
    
    func requestCondition() -> Future<Condition, Error> {
        return .init { [weak self] promise in
            self?.configurePromise(promise)
        }
    }
    
    func setAgreedCondition() {
        settingService.save(key: .agreedCondition, value: true)
    }
    
    private func configurePromise(_ promise: @escaping ((Result<Condition, Error>) -> Void)) {
        useCase
            .getCondition()
            .receive(on: queue)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { condition in
                promise(.success(condition))
            }
            .store(in: &cancellableBag)
    }
    
    private func configureQueue() {
        queue.qualityOfService = .userInteractive
    }
}
