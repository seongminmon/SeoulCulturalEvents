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
    private let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .categoryLayout()).then {
        $0.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier
        )
        $0.register(
            CategoryCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryCollectionHeaderView.identifier
        )
        $0.showsHorizontalScrollIndicator = false
    }
//    private let emptyView = UILabel().then {
//        $0.text = "최근 검색 이력이 없습니다."
//        $0.font = .regular15
//        $0.textColor = .systemGray
//        $0.textAlignment = .center
//    }
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = SearchViewModel.Input(
            searchText: searchBar.rx.text.orEmpty,
            searchButtonTap: searchBar.rx.searchButtonClicked,
            categoryCellTap: categoryCollectionView.rx.itemSelected
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, String>> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryCollectionViewCell.identifier,
                for: indexPath
            ) as? CategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(item)
            return cell
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryCollectionHeaderView.identifier,
                for: indexPath
            ) as? CategoryCollectionHeaderView else {
                return UICollectionReusableView()
            }
            let section = dataSource.sectionModels[indexPath.section]
            header.configureHeader(section.model)
            return header
        }
        
        output.categoryList
            .bind(to: categoryCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "문화 행사 검색"
    }
    
    override func setLayout() {
        [
            searchBar,
            categoryCollectionView,
//            emptyView
        ].forEach {
            view.addSubview($0)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
//        emptyView.snp.makeConstraints { make in
//            make.top.equalTo(categoryCollectionView.snp.bottom).offset(8)
//            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
    }
}
