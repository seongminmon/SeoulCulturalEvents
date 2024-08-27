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
    
    private var sections: [SearchSection] = [
        SearchSection(model: "최근 검색어", items: UserDefaultsManager.recentSearchTerms),
        SearchSection(model: "카테고리", items: CodeName.allCases.map { $0.rawValue} )
    ]
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchText: ControlProperty<String>
        let searchButtonTap: ControlEvent<Void>
        let cellTap: ControlEvent<IndexPath>
        let deleteTerms: PublishSubject<IndexPath>
    }
    
    struct Output {
        let sections: BehaviorSubject<[SearchSection]>
        let cultureParameter: Observable<CultureParameter>
    }
    
    func transform(input: Input) -> Output {
        
        let sections = BehaviorSubject(value: sections)
        let cultureParameter = PublishSubject<CultureParameter>()
        
        input.searchButtonTap
            .withLatestFrom(input.searchText)
            .subscribe(with: self) { owner, query in
                // 최근 검색어 갱신
                if let index = UserDefaultsManager.recentSearchTerms.firstIndex(of: query) {
                    UserDefaultsManager.recentSearchTerms.remove(at: index)
                }
                UserDefaultsManager.recentSearchTerms.insert(query, at: 0)
                owner.sections[0].items = UserDefaultsManager.recentSearchTerms
                sections.onNext(owner.sections)
                
                // parameter 생성
                let parameter = CultureParameter(startIndex: 1, endIndex: 20, title: query)
                cultureParameter.onNext(parameter)
            }
            .disposed(by: disposeBag)
        
        input.deleteTerms
            .subscribe(with: self) { owner, indexPath in
                UserDefaultsManager.recentSearchTerms.remove(at: indexPath.item)
                owner.sections[indexPath.section].items = UserDefaultsManager.recentSearchTerms
                sections.onNext(owner.sections)
            }
            .disposed(by: disposeBag)
        
        input.cellTap
            .subscribe(with: self) { owner, indexPath in
                var parameter = CultureParameter(startIndex: 1, endIndex: 20)
                switch indexPath.section {
                case 0:
                    let title = owner.sections[0].items[indexPath.item]
                    
                    // 최근 검색어 갱신
                    if let index = UserDefaultsManager.recentSearchTerms.firstIndex(of: title) {
                        UserDefaultsManager.recentSearchTerms.remove(at: index)
                        UserDefaultsManager.recentSearchTerms.insert(title, at: 0)
                    }
                    owner.sections[indexPath.section].items = UserDefaultsManager.recentSearchTerms
                    sections.onNext(owner.sections)
                    
                    parameter.title = title
                case 1:
                    parameter.codeName = CodeName.allCases[indexPath.item]
                default:
                    break
                }
                cultureParameter.onNext(parameter)
            }
            .disposed(by: disposeBag)
        
        return Output(
            sections: sections,
            cultureParameter: cultureParameter
        )
    }
}
