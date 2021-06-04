//
//  UIViewController+ErrorAlert.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/4/21.
//

import UIKit

extension UIViewController {
    func showErrorAlert(_ error: Error, completion: (() -> Void)? = nil) {
        let alertViewController: UIAlertController = .init(title: "오류!",
                                                           message: error.localizedDescription, preferredStyle: .alert)
        let doneAction: UIAlertAction = .init(title: "확인",
                                              style: .default,
                                              handler: nil)
        
        alertViewController.addAction(doneAction)
        present(alertViewController, animated: true, completion: completion)
    }
}
