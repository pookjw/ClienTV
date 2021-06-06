//
//  CommentListViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/6/21.
//

import UIKit
import SnapKit

final class CommentListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label: UILabel = .init()
        label.text = "구현 예정!"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    func requestCommentList(boardPath: String, articlePath: String) {
        
    }
}
