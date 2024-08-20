//
//  TodayViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/18/24.
//

import Foundation
import RxSwift
import RxCocoa

final class TodayViewModel: ViewModelType {
    
    // TODO: - 페이지 네이션 기능 구현하기
    
    private let disposeBag = DisposeBag()
    private var cultureResponse: CultureResponse?
    private var page = 1
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let cellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
        let cultureList: BehaviorSubject<[CulturalEvent]>
        let networkFailure: PublishSubject<String>
        let cellTap: PublishSubject<CulturalEvent>
    }
    
    func transform(input: Input) -> Output {
        
        let cultureList = BehaviorSubject<[CulturalEvent]>(value: cultureResponse?.culturalEventInfo.list ?? [])
        let networkFailure = PublishSubject<String>()
        let cellTap = PublishSubject<CulturalEvent>()
        
        input.viewDidLoad
            .withUnretained(self)
            .flatMap { _ in
                let cultureParameter = CultureParameter(startIndex: self.page, endIndex: self.page + 20, codeName: nil, title: nil, date: Date())
                return CultureAPIManager.shared.callRequest(cultureParameter)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("문화 행사 통신 성공")
                    owner.cultureResponse = data
                    guard let list = owner.cultureResponse?.culturalEventInfo.list else { return }
                    cultureList.onNext(list)
                    
                case .failure(let error):
                    print("문화 행사 통신 실패")
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
        
        
        return Output(
            cultureList: cultureList,
            networkFailure: networkFailure,
            cellTap: cellTap
        )
    }
}
