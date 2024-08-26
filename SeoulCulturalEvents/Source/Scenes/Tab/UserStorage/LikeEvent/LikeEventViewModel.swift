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
        
    }
    
    struct Output {
        let eventList: BehaviorSubject<[CulturalEvent]>
    }
    
    func transform(input: Input) -> Output {
        
        let eventList = BehaviorSubject<[CulturalEvent]>(value: [])
        
        LSLPAPIManager.shared.callRequest(api: .fetchUserPostList(userID: userID), model: PostModelList.self)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("내 포스트 조회 성공")
                    dump(data)
                    owner.postResponse = data
                    let list = data.data
                        .filter { $0.postID != ProductID.post }
                        .compactMap { $0.content?.toCulturalEvent() }
                    eventList.onNext(list)
                    
                case .failure(let error):
                    print("내 포스트 조회 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            eventList: eventList
        )
    }
}
