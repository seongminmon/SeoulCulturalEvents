//
//  SearchViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

final class SearchViewModel: ViewModelType {
    
    // TODO: - 최근 검색어 기능 구현하기
    
    struct Input {
        let searchText: ControlProperty<String>
        let searchButtonTap: ControlEvent<Void>
        let categoryCellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
        let categoryList: Observable<[Section]>
        let cultureParameter: Observable<CultureParameter>
    }
    
    typealias Section = AnimatableSectionModel<String, String>
    
    private let sections: [Section] = [
//        Section(model: "최근 검색어", items: ["test1", "test2", "test3", "test4", "test5"]),
        Section(model: "카테고리", items: CodeName.allCases.map { $0.rawValue} )
    ]
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
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
            categoryList: Observable.just(sections),
            cultureParameter: Observable.merge(categorySelected, searchButtonTap)
        )
    }
}
