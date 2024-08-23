//
//  SearchViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
    
    // TODO: - 최근 검색어 기능 구현하기
    
    struct Input {
        let searchText: ControlProperty<String>
        let searchButtonTap: ControlEvent<Void>
        let categoryCellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
        let categoryList: BehaviorSubject<[SearchSection]>
        let cultureParameter: Observable<CultureParameter>
    }
    
    private let sections: [SearchSection] = [
//        SearchSection(model: "최근 검색어", items: ["test1", "test2", "test3", "test4", "test5"]),
        SearchSection(model: "카테고리", items: CodeName.allCases.map { $0.rawValue} )
    ]
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let categoryList = BehaviorSubject(value: sections)
        let searchButtonTap = PublishSubject<CultureParameter>()
        let categorySelected = PublishSubject<CultureParameter>()
        
        input.searchButtonTap
            .withLatestFrom(input.searchText)
            .subscribe(with: self) { owner, query in
                let parameter = CultureParameter(startIndex: 1, endIndex: 20, title: query)
                categorySelected.onNext(parameter)
            }
            .disposed(by: disposeBag)
        
        input.categoryCellTap
            .subscribe(with: self) { owner, indexPath in
                let codeName = CodeName.allCases[indexPath.item]
                let parameter = CultureParameter(startIndex: 1, endIndex: 20, codeName: codeName)
                categorySelected.onNext(parameter)
            }
            .disposed(by: disposeBag)
        
        return Output(
            categoryList: categoryList,
            cultureParameter: Observable.merge(categorySelected, searchButtonTap)
        )
    }
}
