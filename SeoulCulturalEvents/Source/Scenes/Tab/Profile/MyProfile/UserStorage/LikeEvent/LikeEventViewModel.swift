//
//  LikeEventViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeEventViewModel: ViewModelType {
    
    init(userID: String) {
        self.userID = userID
    }
    
    private let userID: String
    private var postResponse: PostModelList?
    private let disposeBag = DisposeBag()
    
    struct Input {
        let cellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
        let eventList: BehaviorSubject<[CulturalEvent]>
        let networkFailure: PublishSubject<String>
        let cellTap: PublishSubject<CulturalEvent>
    }
    
    func transform(input: Input) -> Output {
        
        let eventList = BehaviorSubject<[CulturalEvent]>(value: [])
        let networkFailure = PublishSubject<String>()
        let cellTap = PublishSubject<CulturalEvent>()
        
        // 내 포스트 조회 -> productID 후기인 것들 제외
        let query = PostFetchQuery()
        LSLPAPIManager.shared.callRequestWithRetry(
            api: .fetchUserPostList(userID: userID, query: query),
            model: PostModelList.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let data):
                print("내 포스트 조회 성공")
                owner.postResponse = data
                let list = data.data
                    .filter { $0.productID != ProductID.post }
                    .compactMap { $0.content?.toCulturalEvent() }
                eventList.onNext(list)
                
            case .failure(let error):
                print("내 포스트 조회 실패")
                print(error)
                networkFailure.onNext(error.localizedDescription)
            }
        }
        .disposed(by: disposeBag)
        
        input.cellTap
            .subscribe(with: self) { owner, indexPath in
                guard let list = try? eventList.value() else { return }
                let item = list[indexPath.row]
                cellTap.onNext(item)
            }
            .disposed(by: disposeBag)
        
        return Output(
            eventList: eventList,
            networkFailure: networkFailure,
            cellTap: cellTap
        )
    }
}
