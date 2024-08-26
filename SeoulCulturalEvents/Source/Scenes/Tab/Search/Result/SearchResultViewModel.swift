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
    
    private var cultureParameter: CultureParameter
    private var cultureResponse: CultureResponse?
    private var start = 1
    private let disposeBag = DisposeBag()
    
    init(cultureParameter: CultureParameter) {
        self.cultureParameter = cultureParameter
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let cellTap: ControlEvent<IndexPath>
        let filterButtonTap: ControlEvent<Void>
        let filterAction: PublishSubject<FilterOption>
        let prefetchRows: ControlEvent<[IndexPath]>
    }
    
    struct Output {
        let navigationTitle: BehaviorSubject<String?>
        let cultureList: BehaviorSubject<[CulturalEvent]>
        let networkFailure: PublishSubject<String>
        let cellTap: PublishSubject<CulturalEvent>
        let filterButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        
        // TODO: - 페이지네이션 구현
        
        let navigationTitle = BehaviorSubject<String?>(value: nil)
        let cultureList = BehaviorSubject<[CulturalEvent]>(value: cultureResponse?.culturalEventInfo.list ?? [])
        let networkFailure = PublishSubject<String>()
        let cellTap = PublishSubject<CulturalEvent>()
        
        // 검색어/카테고리 진입 분기처리
        if let title = cultureParameter.title {
            navigationTitle.onNext(title)
        } else {
            navigationTitle.onNext(cultureParameter.codeName?.rawValue)
        }
        
        // 받아온 파라미터로 문화행사 통신
        input.viewDidLoad
            .withUnretained(self)
            .flatMap { _ in
                CultureAPIManager.shared.callRequest(self.cultureParameter)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("문화행사 검색 성공")
                    print(data.culturalEventInfo.totalCount)
                    owner.cultureResponse = data
                    guard let list = owner.cultureResponse?.culturalEventInfo.list else { return }
                    cultureList.onNext(list)
                    
                case .failure(let error):
                    print("문화행사 검색 실패")
                    print(error.errorDescription ?? "문화행사 검색 실패")
                    networkFailure.onNext(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.cellTap
            .subscribe(with: self) { owner, indexPath in
                guard let item = owner.cultureResponse?.culturalEventInfo.list[indexPath.row] else { return }
                cellTap.onNext(item)
            }
            .disposed(by: disposeBag)
        
        // 페이지 네이션
//        input.prefetchRows
//            .compactMap { indexPaths -> Void? in
//                print(indexPaths)
//                guard let cultureResponse = self.cultureResponse,
//                        self.start + 20 <= cultureResponse.culturalEventInfo.totalCount else { return nil }
//                
//                for indexPath in indexPaths {
//                    if indexPath.row == cultureResponse.culturalEventInfo.list.count - 1 {
//                        self.start += 20
//                        return nil
//                    }
//                }
//                return ()
//            }
//            .flatMap { _ in
//                let cultureParameter = CultureParameter(
//                    startIndex: self.start,
//                    endIndex: self.start + 19,
//                    codeName: nil, title: nil,
//                    date: Date()
//                )
//                print(cultureParameter)
//                return CultureAPIManager.shared.callRequest(cultureParameter)
//            }
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let data):
//                    print("문화 행사 통신 페이지네이션 성공")
//                    owner.cultureResponse?.culturalEventInfo.list.append(contentsOf: data.culturalEventInfo.list)
//                    guard let list = owner.cultureResponse?.culturalEventInfo.list else { return }
//                    cultureList.onNext(list)
//                    
//                case .failure(let error):
//                    print("문화 행사 통신 페이지네이션 실패")
//                    networkFailure.onNext(error.localizedDescription)
//                }
//            }
//            .disposed(by: disposeBag)
        
        // 액션 시트에서 선택 시 전체 / 현재 진행 중 토글 기능
        input.filterAction
            .compactMap { option -> Void? in
                switch option {
                case .total:
                    if self.cultureParameter.date == nil { return nil }
                    self.cultureParameter.date = nil
                case .now:
                    if self.cultureParameter.date != nil { return nil }
                    self.cultureParameter.date = Date()
                }
            }
            .flatMap { _ in
                CultureAPIManager.shared.callRequest(self.cultureParameter)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("문화행사 필터 검색 성공")
                    owner.cultureResponse = data
                    guard let list = owner.cultureResponse?.culturalEventInfo.list else { return }
                    cultureList.onNext(list)
                    
                case .failure(let error):
                    print("문화행사 필터 검색 실패")
                    print(error.errorDescription ?? "문화행사 필터 검색 실패")
                    networkFailure.onNext(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
            
        
        return Output(
            navigationTitle: navigationTitle,
            cultureList: cultureList,
            networkFailure: networkFailure,
            cellTap: cellTap,
            filterButtonTap: input.filterButtonTap
        )
    }
}
