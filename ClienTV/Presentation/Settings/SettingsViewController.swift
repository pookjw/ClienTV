//
//  SettingsViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit
import SnapKit

final class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label: UILabel = .init()
        label.text = "구현 예정!"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}
