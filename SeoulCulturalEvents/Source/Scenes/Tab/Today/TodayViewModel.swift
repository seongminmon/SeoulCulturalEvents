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
    
    private lazy var cultureParameter = CultureParameter(startIndex: 1, endIndex: 20, date: Date())
    private var cultureResponse: CultureResponse?
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let cellTap: ControlEvent<IndexPath>
        let prefetchRows: ControlEvent<[IndexPath]>
    }
    
    struct Output {
        let cultureList: BehaviorSubject<[CulturalEvent]>
        let networkFailure: PublishSubject<String>
        let cellTap: PublishSubject<CulturalEvent>
    }
    
    func transform(input: Input) -> Output {
        
        let cultureList = BehaviorSubject<[CulturalEvent]>(value: [])
        let networkFailure = PublishSubject<String>()
        let cellTap = PublishSubject<CulturalEvent>()
        
        // 첫 통신
        input.viewDidLoad
            .withUnretained(self)
            .flatMap { _ in
                CultureAPIManager.shared.callRequest(self.cultureParameter)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("문화 행사 통신 성공")
                    print(data.culturalEventInfo.totalCount)
                    owner.cultureResponse = data
                    guard let list = owner.cultureResponse?.culturalEventInfo.list else { return }
                    cultureList.onNext(list)
                    
                case .failure(let error):
                    print("문화 행사 통신 실패")
                    networkFailure.onNext(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 페이지 네이션
        input.prefetchRows
            .compactMap { indexPaths -> Void? in
                print(indexPaths)
                guard let cultureResponse = self.cultureResponse,
                      self.cultureParameter.startIndex + 20 <= cultureResponse.culturalEventInfo.totalCount else { return nil }
                
                for indexPath in indexPaths {
                    if indexPath.row == cultureResponse.culturalEventInfo.list.count - 1 {
                        return ()
                    }
                }
                return nil
            }
            .flatMap { _ in
                self.cultureParameter.startIndex += 20
                self.cultureParameter.endIndex += 20
                print(self.cultureParameter)
                return CultureAPIManager.shared.callRequest(self.cultureParameter)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("문화 행사 통신 페이지네이션 성공")
                    owner.cultureResponse?.culturalEventInfo.list.append(contentsOf: data.culturalEventInfo.list)
                    guard let list = owner.cultureResponse?.culturalEventInfo.list else { return }
                    cultureList.onNext(list)
                    
                case .failure(let error):
                    print("문화 행사 통신 페이지네이션 실패")
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
