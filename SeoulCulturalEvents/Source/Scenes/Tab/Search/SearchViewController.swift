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
    private let searchCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .searchLayout()).then {
        $0.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.identifier
        )
        $0.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier
        )
        $0.register(
            SearchCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchCollectionHeaderView.identifier
        )
        $0.keyboardDismissMode = .onDrag
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
        let deleteTerms = PublishSubject<IndexPath>()
        
        let input = SearchViewModel.Input(
            searchText: searchBar.rx.text.orEmpty,
            searchButtonTap: searchBar.rx.searchButtonClicked,
            cellTap: searchCollectionView.rx.itemSelected,
            deleteTerms: deleteTerms
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<SearchSection> { dataSource, collectionView, indexPath, item in
            switch indexPath.section {
            case 0:
                // 최근 검색어 섹션
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchCollectionViewCell.identifier,
                    for: indexPath
                ) as? SearchCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configureCell(item)
                cell.deleteButton.rx.tap
                    .bind(with: self) { owner, _ in
                        // MARK: - indexPath로 가져오면 인덱스가 밀리게 됨 >> cell의 indexPath 가져오기
                        if let indexPath = collectionView.indexPath(for: cell) {
                            deleteTerms.onNext(indexPath)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                return cell
                
            case 1:
                // 카테고리 섹션
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CategoryCollectionViewCell.identifier,
                    for: indexPath
                ) as? CategoryCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configureCell(item)
                return cell
                
            default: break
            }
            return UICollectionViewCell()
            
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SearchCollectionHeaderView.identifier,
                for: indexPath
            ) as? SearchCollectionHeaderView else {
                return UICollectionReusableView()
            }
            let section = dataSource.sectionModels[indexPath.section]
            header.configureHeader(section.model)
            return header
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
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
