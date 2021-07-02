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
        configureAddBarButtonItem()
        configureCollectionView()
        configureViewModel()
    }
    
    private func setAttributes() {
        title = "차단단어 설정"
    }
    
    private func configureAddBarButtonItem() {
        let addBarButtonItemAction: UIAction = .init { [weak self] _ in
            
        }
        
        let addBarButtonItem: UIBarButtonItem = .init(title: nil,
                                                      image: .init(systemName: "plus"),
                                                      primaryAction: addBarButtonItemAction,
                                                      menu: nil)
        
        navigationItem.rightBarButtonItem = addBarButtonItem
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
}

// MARK: - UICollectionViewDelegate

extension FilterSettingListViewController: UICollectionViewDelegate {
    
}
