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
    
    struct Input {
        let searchText: ControlProperty<String>
        let searchButtonTap: ControlEvent<Void>
        let categoryCellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
        let categoryList: BehaviorSubject<[Section]>
    }
    
    typealias Section = AnimatableSectionModel<String, String>
    
    private let sections: [Section] = [
//        Section(model: "최근 검색어", items: ["test1", "test2", "test3", "test4", "test5"]),
        Section(model: "카테고리", items: CodeName.allCases.map { $0.rawValue} )
    ]
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let categoryList = BehaviorSubject(value: sections)
        
        input.searchButtonTap
            .subscribe(with: self) { owner, _ in
                print("검색 버튼 탭")
            }
            .disposed(by: disposeBag)
        
        input.categoryCellTap
            .subscribe(with: self) { owner, indexPath in
                print("카테고리 셀 탭 \(indexPath)")
            }
            .disposed(by: disposeBag)
        
        return Output(
            categoryList: categoryList
        )
    }
}
