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
    
    var canDismissViaMenuButton: Bool = false
    private var viewModel: ConditionViewModel!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    // -300 offset 부여. 없어도 상관은 없음.
    private var isRecheadToBottom: Bool {
        return (bodyTextView.contentOffset.y >= (bodyTextView.contentSize.height - bodyTextView.frame.height - 300))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        clearContents()
        configureViewModel()
        requestCondition()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if canDismissViaMenuButton {
            super.dismiss(animated: flag, completion: completion)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        defer {
            super.pressesEnded(presses, with: event)
        }
        
        guard let press: UIPress = presses.first else {
            return
        }

        if press.type == .menu {
            if isRecheadToBottom {
//                confirmButton.isEnabled = true
//                preferredFocusEnvironments = [confirmButton]
            }
        }
    }
    
    private func setAttributes() {
        bodyTextView.isUserInteractionEnabled = true
        bodyTextView.isSelectable = true
        bodyTextView.isScrollEnabled = true
        bodyTextView.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.indirect.rawValue] as [NSNumber]
        bodyTextView.delegate = self
        
        title = "이용약관"
    }
    
    private func clearContents() {
        bodyTextView.text = nil
        confirmButton.isEnabled = false
        confirmButton.setTitle("끝까지 읽어 주세요!", for: .normal)
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
    }
    
    private func makeConfirmButtonEnabledIfNeeded() {
        if isRecheadToBottom {
            confirmButton.isEnabled = true
            confirmButton.setTitle("이용약관에 동의합니다.", for: .normal)
        }
    }
    
    @IBAction func pressedConfirmButton(_ sender: UIButton) {
        viewModel.setAgreedCondition()
        super.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension ConditionViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        makeConfirmButtonEnabledIfNeeded()
    }
}
