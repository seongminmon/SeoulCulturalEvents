//
//  SearchResultViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchResultViewModel: ViewModelType {
    
    private let cultureParameter: CultureParameter
    private let disposeBag = DisposeBag()
    
    init(cultureParameter: CultureParameter) {
        self.cultureParameter = cultureParameter
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
}

//    private var cultureResponse: CultureResponse?
//    lazy var cultureParameter = CultureParameter(startIndex: start, endIndex: start + 20, codeName: nil, title: nil, date: nil)
//    private var start = 1

//input.searchButtonTap
//    .withLatestFrom(input.searchText)
//    .debounce(.seconds(1), scheduler: MainScheduler.instance)
////            .distinctUntilChanged()
//    .flatMap { value in
//        // 페이지 초기화, 검색어 갱신 후 통신
//        self.start = 1
//        self.cultureParameter.startIndex = self.start
//        self.cultureParameter.endIndex = self.start + 20
//        self.cultureParameter.title = value
//        print(self.cultureParameter)
//        return CultureAPIManager.shared.callRequest(self.cultureParameter)
//    }
//    .subscribe(with: self) { owner, result in
//        switch result {
//        case .success(let data):
//            print("문화행사 검색 성공")
//            dump(data)
//            owner.cultureResponse = data
//            
//        case .failure(let error):
//            print("문화행사 검색 실패")
//            print(error)
//        }
//    }
//    .disposed(by: disposeBag)

//input.categoryCellTap
//    .subscribe(with: self) { owner, value in
//        owner.cultureParameter.codeName = owner.cultureParameter.codeName == CodeName(rawValue: value) ? nil : CodeName(rawValue: value)
//        categoryList.onNext(owner.categoryList)
//    }
//    .disposed(by: disposeBag)
