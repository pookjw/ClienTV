//
//  SettingsViewController.swift
//  ClienTV
//
//  Created by Jinwoo Kim on 6/3/21.
//

import UIKit
import SnapKit

final class SettingsViewController: UIViewController {
    private weak var collectionView: UICollectionView!
    private var viewModel: SettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.identifier)
        collectionView.register(UICollectionViewListCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionViewListCell.identifier)
        collectionView.delegate = self
    }
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration: UICollectionLayoutListConfiguration = .init(appearance: .grouped)
            
            configuration.headerMode = .supplementary
            
            return .list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func configureViewModel() {
        let viewModel: SettingsViewModel = .init(dataSource: getDataSource())
        self.viewModel = viewModel
    }
    
    private func getDataSource() -> SettingsViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionView is not configured!")
        }
        
        let dataSource: SettingsViewModel.DataSource = .init(collectionView: collectionView, cellProvider: getCellProvider())
        
        dataSource.supplementaryViewProvider = getSupplementaryViewProvider()
        
        return dataSource
    }
    
    private func getCellProvider() -> SettingsViewModel.DataSource.CellProvider {
        return { (collectionView, indexPath, cellItem) -> UICollectionViewCell? in
            
            guard let cell: UICollectionViewListCell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            switch cellItem.dataType {
            case .toggleBoardPathVisibility(let data):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = data.title
                configuration.image = data.image
                configuration.imageToTextPadding = 30
                cell.contentConfiguration = configuration
                cell.accessories = [.label(text: data.accessoryText)]
            case .developerEmail(let data):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = data.title
                configuration.secondaryText = data.subTitle
                configuration.image = data.image
                configuration.imageToTextPadding = 30
                cell.contentConfiguration = configuration
                cell.accessories = []
            case .developerGitHub(let data):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = data.title
                configuration.secondaryText = data.subTitle
                configuration.image = data.image
                configuration.imageToTextPadding = 30
                cell.contentConfiguration = configuration
                cell.accessories = []
            case .presentCondition(let data):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = data.title
                configuration.image = data.image
                configuration.imageToTextPadding = 30
                cell.contentConfiguration = configuration
                cell.accessories = [.disclosureIndicator()]
            case .presentFilterSetting(let data):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = data.title
                configuration.image = data.image
                configuration.imageToTextPadding = 30
                cell.contentConfiguration = configuration
                cell.accessories = [.disclosureIndicator()]
            }
            
            return cell
        }
    }
    
    private func getSupplementaryViewProvider() -> SettingsViewModel.DataSource.SupplementaryViewProvider {
        return { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            
            guard let headerView: UICollectionViewListCell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: UICollectionViewListCell.identifier, for: indexPath) as? UICollectionViewListCell else {
                return nil
            }
            
            guard let headerItem: SettingsHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return nil
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            configuration.text = headerItem.title
            headerView.contentConfiguration = configuration
            
            return headerView
        }
    }
    
    private func presentConditionViewController() {
        let conditionViewController: ConditionViewController = .loadFromNib()
        let navigationController: UINavigationController = .init(rootViewController: conditionViewController)
        conditionViewController.canDismissViaMenuButton = true
        conditionViewController.loadViewIfNeeded()
        navigationController.loadViewIfNeeded()
        present(navigationController, animated: true, completion: nil)
    }
    
    private func presentFilterSettingListViewController() {
        let filterSettingViewController: FilterSettingListViewController = .init()
        let navigationController: UINavigationController = .init(rootViewController: filterSettingViewController)
        filterSettingViewController.loadViewIfNeeded()
        navigationController.loadViewIfNeeded()
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate
extension SettingsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        guard let cellItem: SettingsCellItem = viewModel.getCellItem(from: indexPath) else {
            return
        }
        
        switch cellItem.dataType {
        case .toggleBoardPathVisibility(_):
            viewModel.toggleBoardPathVisibility()
        case .presentCondition:
            presentConditionViewController()
        case .presentFilterSetting:
            presentFilterSettingListViewController()
        default:
            break
        }
    }
}
