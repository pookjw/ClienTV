//
//  FilterSettingListViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 7/2/21.
//

import UIKit
import SnapKit

final class FilterSettingListViewController: UIViewController {
    private weak var collectionView: UICollectionView!
    private var viewModel: FilterSettingListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCreateBarButtonItem()
        configureCollectionView()
        configureViewModel()
    }
    
    private func setAttributes() {
        title = "차단단어 설정"
    }
    
    private func configureCreateBarButtonItem() {
        let createBarButtonItem: UIBarButtonItem = .init(image: .init(systemName: "plus"),
                                                      style: .plain, target: self, action: #selector(pressedCreateBarButtonItem(_:)))
        
        navigationItem.rightBarButtonItems = [createBarButtonItem]
    }
    
    @objc private func pressedCreateBarButtonItem(_ sender: UIBarButtonItem) {
        presentCreateAlertViewController()
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.identifier)
        collectionView.delegate = self
    }
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let configuration: UICollectionLayoutListConfiguration = .init(appearance: .grouped)
            
            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func configureViewModel() {
        let viewModel: FilterSettingListViewModel = .init(dataSource: getDataSource())
        self.viewModel = viewModel
    }
    
    private func getDataSource() -> FilterSettingListViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: FilterSettingListViewModel.DataSource = .init(collectionView: collectionView, cellProvider: getCellProvider())
        
        return dataSource
    }
    
    private func getCellProvider() -> FilterSettingListViewModel.DataSource.CellProvider {
        return { (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
            
            guard let cell: UICollectionViewListCell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            switch cellItem.dataType {
            case .filterSetting(let data):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = data.text
                cell.contentConfiguration = configuration
            }
            
            return cell
        }
    }
    
    private func presentCreateAlertViewController() {
        let alertVC: UIAlertController = .init(title: "차단단어 입력",
                                               message: "차단할 단어를 입력해 주세요. 글의 제목, 작성자 닉네임을 차단해 줍니다.",
                                               preferredStyle: .alert)
        
        let createButton: UIAlertAction = .init(title: "추가",
                                              style: .default) { [weak self, weak alertVC] _ in
            
            guard let textField: UITextField = alertVC?.textFields?.first,
                  let text: String = textField.text else {
                      return
                  }
            
            self?.viewModel?.createFilterSetting(text: text)
        }
        
        let cancelButton: UIAlertAction = .init(title: "취소",
                                                style: .cancel,
                                                handler: nil)
        
        alertVC.addAction(createButton)
        alertVC.addAction(cancelButton)
        
        alertVC.addTextField { textField in
            textField.placeholder = "입력"
        }
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func presentRemoveAlertViewController(filterSettingData: FilterSettingCellItem.FilterSettingData) {
        let toRemoveText: String = filterSettingData.text
        let title: String = "\"\(toRemoveText)\" 차단단어를 삭제하실래요?🧐"
        let alertVC: UIAlertController = .init(title: title,
                                               message: nil,
                                               preferredStyle: .alert)
        
        let removeButton: UIAlertAction = .init(title: "네",
                                                style: .destructive) { [weak self] _ in
            self?.viewModel?.removeFilterSetting(text: toRemoveText)
        }
        
        let cancelButton: UIAlertAction = .init(title: "취소",
                                                style: .cancel,
                                                handler: nil)
        
        alertVC.addAction(removeButton)
        alertVC.addAction(cancelButton)
        
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate

extension FilterSettingListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellItem: FilterSettingCellItem = viewModel?.getCellItem(from: indexPath) else {
            return
        }
        
        switch cellItem.dataType {
        case .filterSetting(let data):
            presentRemoveAlertViewController(filterSettingData: data)
        }
    }
}
