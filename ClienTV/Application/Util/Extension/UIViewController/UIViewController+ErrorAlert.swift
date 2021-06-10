//
//  UIViewController+ErrorAlert.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit

extension UIViewController {
    func showErrorAlert(_ error: Error, completion: ((UIAlertAction) -> Void)? = nil) {
        let errorDescription: String?
        
        if let error: LocalizedError = error as? LocalizedError{
            errorDescription = error.errorDescription
        } else {
            errorDescription = error.localizedDescription
        }
        
        let alertViewController: UIAlertController = .init(title: "오류!",
                                                           message: errorDescription, preferredStyle: .alert)
        let doneAction: UIAlertAction = .init(title: "확인",
                                              style: .default,
                                              handler: completion)
        
        alertViewController.addAction(doneAction)
        present(alertViewController, animated: true, completion: nil)
    }
}
