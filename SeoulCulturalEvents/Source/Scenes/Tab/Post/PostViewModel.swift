//
//  PostViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostViewModel: ViewModelType {
    
    private var recentNetworkTime: DispatchTime?
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let cellTap: ControlEvent<PostModel>
        let refreshEvent: ControlEvent<Void>
    }
    
    struct Output {
        let postList: BehaviorSubject<[PostModel]>
        let cellTap: ControlEvent<PostModel>
        let remainTime: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let postList = BehaviorSubject<[PostModel]>(value: [])
        let remainTime = PublishSubject<Void>()
        
        // 포스트 조회 통신
        Observable.merge(input.viewDidLoad, input.refreshEvent.asObservable())
            .flatMap { () -> Single<Result<PostModelList, LSLPError>> in
                // 10초가 안 지났으면 통신 X
                if let recentNetworkTime = self.recentNetworkTime,
                    recentNetworkTime + 10 > .now() {
                    remainTime.onNext(())
                    return Single.just(.failure(LSLPError.unknown))
                }
                let query = PostFetchQuery(next: nil, productID: ProductID.post)
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: .fetchPostList(query: query),
                    model: PostModelList.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 조회 성공")
                    owner.recentNetworkTime = .now()
                    postList.onNext(data.data)
                    
                case .failure(let error):
                    print("포스트 조회 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            postList: postList,
            cellTap: input.cellTap,
            remainTime: remainTime
        )
    }
}
