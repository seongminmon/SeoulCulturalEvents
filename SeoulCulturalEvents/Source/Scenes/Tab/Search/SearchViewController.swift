//
//  SearchViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class SearchViewController: BaseViewController {
    
    private let searchBar = UISearchBar().then {
        $0.placeholder = "문화 행사명을 검색해보세요"
    }
    private let searchCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .searchLayout()
    ).then {
        $0.keyboardDismissMode = .onDrag
        $0.showsHorizontalScrollIndicator = false
    }
    
    private var searchCellRegistration: UICollectionView.CellRegistration<SearchCollectionViewCell, String>!
    private var categoryCellRegistration: UICollectionView.CellRegistration<CategoryCollectionViewCell, String>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<SearchCollectionHeaderView>!
    
    private let deleteTerms = PublishSubject<IndexPath>()
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewRegistration(viewModel.sections)
    }
    
    override func bind() {
        
        let input = SearchViewModel.Input(
            searchText: searchBar.rx.text.orEmpty,
            searchButtonTap: searchBar.rx.searchButtonClicked,
            cellTap: searchCollectionView.rx.itemSelected,
            deleteTerms: deleteTerms
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<SearchSection> { [weak self] dataSource, collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch indexPath.section {
            case 0:
                // 최근 검색어 섹션
                return collectionView.dequeueConfiguredReusableCell(
                    using: searchCellRegistration,
                    for: indexPath,
                    item: item
                )
                
            case 1:
                // 카테고리 섹션
                return collectionView.dequeueConfiguredReusableCell(
                    using: categoryCellRegistration,
                    for: indexPath,
                    item: item
                )
                
            default:
                return UICollectionViewCell()
            }
            
        } configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
            guard let self else { return UICollectionReusableView() }
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: self.headerRegistration,
                for: indexPath
            )
        }
        
        output.sections
            .bind(to: searchCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.cultureParameter
            .subscribe(with: self) { owner, parameter in
                let vm = SearchResultViewModel(cultureParameter: parameter)
                let vc = SearchResultViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "문화 행사 검색"
    }
    
    override func setLayout() {
        [
            searchBar,
            searchCollectionView
        ].forEach {
            view.addSubview($0)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        searchCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureCollectionViewRegistration(_ models: [SearchSection]) {
        searchCellRegistration = UICollectionView.CellRegistration<SearchCollectionViewCell, String> { cell, indexPath, item in
            cell.configureCell(item)
            cell.deleteButton.rx.tap
                .bind(with: self) { owner, _ in
                    // MARK: - indexPath로 가져오면 인덱스가 밀리게 됨 >> cell의 indexPath 가져오기
                    if let indexPath = owner.searchCollectionView.indexPath(for: cell) {
                        owner.deleteTerms.onNext(indexPath)
                    }
                }
                .disposed(by: cell.disposeBag)
        }
        
        categoryCellRegistration = UICollectionView.CellRegistration<CategoryCollectionViewCell, String> { cell, indexPath, item in
            cell.configureCell(item)
        }
        
        headerRegistration = UICollectionView.SupplementaryRegistration(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { headeriew, kind, indexPath in
            let header = models[indexPath.section].model
            headeriew.configureHeader(header)
        }
    }
}
