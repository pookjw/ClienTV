//
//  ConditionViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/17/21.
//

import UIKit
import Combine
import OSLog
import ClienTVAPI

final class ConditionViewController: UIViewController {
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var viewModel: ConditionViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        clearContents()
        configureViewModel()
        requestCondition()
    }
    
    private func setAttributes() {
        bodyTextView.isUserInteractionEnabled = true
        bodyTextView.isSelectable = true
        bodyTextView.isScrollEnabled = true
        bodyTextView.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.indirect.rawValue] as [NSNumber]
        bodyTextView.delegate = self
    }
    
    private func clearContents() {
        bodyTextView.text = nil
        confirmButton.isEnabled = false
    }
    
    private func configureViewModel() {
        let viewModel: ConditionViewModel = .init()
        self.viewModel = viewModel
    }
    
    private func requestCondition() {
        let future: Future<Condition, Error> = viewModel
            .requestCondition()
        handleRequestCompletion(future)
    }
    
    private func handleRequestCompletion(_ future: Future<Condition, Error>) {
        future
            .receive(on: OperationQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.error("불러오기 실패! 재시도 중... \(error.localizedDescription)")
                    self?.requestCondition()
                case .finished:
                    break
                }
            } receiveValue: { [weak self] article in
                self?.updateContents(article)
            }
            .store(in: &cancellableBag)
    }
    
    private func updateContents(_ condition: Condition) {
        if let attributedString: NSAttributedString = condition.bodyHTML.convertToAttributedStringFromHTMLWithClear() {
            bodyTextView.attributedText = attributedString
        }
        
        updateConfirmButtonStatus()
    }
    
    private func updateConfirmButtonStatus() {
        // -100 offset 부여. 없어도 상관은 없음.
        let isRecheadToBottom: Bool = (bodyTextView.contentOffset.y >= (bodyTextView.contentSize.height - bodyTextView.frame.height - 100))
        if isRecheadToBottom {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
    
    @IBAction func pressedConfirmButton(_ sender: UIButton) {
        viewModel.setAgreedCondition()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension ConditionViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateConfirmButtonStatus()
    }
}
