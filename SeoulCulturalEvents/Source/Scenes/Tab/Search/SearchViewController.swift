//
//  SearchViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class SearchViewController: BaseViewController {
    
    private let searchBar = UISearchBar().then {
        $0.placeholder = "문화 행사를 검색해보세요."
    }
    private let datePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .compact
        $0.datePickerMode = .date
        $0.locale = Locale(identifier: "ko-KR")
        $0.minimumDate = "2023-08-13".toDate()
    }
    private let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .categoryLayout()).then {
        $0.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        $0.showsHorizontalScrollIndicator = false
    }
//    private let cultureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .categoryLayout()).then {
//        $0.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
//    }
    private let emptyView = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = .bold20
        $0.textAlignment = .center
    }
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = SearchViewModel.Input(
            searchButtonTap: searchBar.rx.searchButtonClicked,
            searchText: searchBar.rx.text.orEmpty,
            categoryCellTap: categoryCollectionView.rx.modelSelected(String.self)
        )
        let output = viewModel.transform(input: input)
        
        // 카테고리 리스트와 연결
        output.categoryList
            .bind(to: categoryCollectionView.rx.items(
                cellIdentifier: CategoryCollectionViewCell.identifier,
                cellType: CategoryCollectionViewCell.self
            )) { [weak self] row, element, cell in
                let flag = self?.viewModel.cultureParameter.codeName?.rawValue == element
                cell.configureView(element)
                cell.toggleSelected(flag)
            }
            .disposed(by: disposeBag)
        
        // 검색 결과 리스트와 연결
        // emptyView랑 cultureCollectionView isHidden 처리
        // 검색 결과 페이지네이션
        
    }
    
    override func setNavigationBar() {
        navigationItem.title = "문화 행사 검색"
    }
    
    override func setLayout() {
        [
            searchBar,
            categoryCollectionView,
            datePicker,
//            cultureCollectionView,
            emptyView
        ].forEach {
            view.addSubview($0)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.trailing.equalTo(datePicker.snp.leading).offset(-8)
            make.height.equalTo(44)
        }
        
        datePicker.snp.makeConstraints { make in
            make.verticalEdges.equalTo(categoryCollectionView)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.equalTo(120)
        }
        
//        cultureCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(categoryCollectionView.snp.bottom).offset(8)
//            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
