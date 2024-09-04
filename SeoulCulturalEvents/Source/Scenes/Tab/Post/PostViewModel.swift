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
    
    private var postFetchQuery = PostFetchQuery(productID: ProductID.post)
    private var postResponse: PostModelList?
    private var recentNetworkTime: DispatchTime?
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let cellTap: ControlEvent<PostModel>
        let refreshEvent: ControlEvent<Void>
        let prefetchItems: ControlEvent<[IndexPath]>
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
            .flatMap { [weak self] () -> Single<Result<PostModelList, LSLPError>> in
                guard let self else { return Single.just(.failure(.unknown)) }
                
                // 10초가 안 지났으면 통신 X
                if let recentNetworkTime = recentNetworkTime,
                    recentNetworkTime + 10 > .now() {
                    remainTime.onNext(())
                    return Single.just(.failure(.unknown))
                }
                
                // 커서 초기화
                postFetchQuery.next = nil
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: PostRouter.fetchPostList(query: postFetchQuery),
                    model: PostModelList.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 조회 성공")
                    owner.postResponse = data
                    owner.recentNetworkTime = .now()
                    postList.onNext(owner.postResponse?.data ?? [])
                    
                    // 다음 커서 세팅
                    owner.postFetchQuery.next = data.nextCursor
                    
                case .failure(let error):
                    print("포스트 조회 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        // 페이지네이션
        input.prefetchItems
            .compactMap { [weak self] indexPaths -> PostFetchQuery? in
                guard let self else { return nil }
                // nextCursor가 "0"이면 패스
                guard let postResponse = postResponse,
                        postFetchQuery.next != "0" else { return nil }
                
                for indexPath in indexPaths {
                    if indexPath.row == postResponse.data.count - 1 {
                        return postFetchQuery
                    }
                }
                return nil
            }
            .flatMap { query in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: PostRouter.fetchPostList(query: query),
                    model: PostModelList.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 조회 페이지네이션 성공")
                    owner.postResponse?.data.append(contentsOf: data.data)
                    owner.postResponse?.nextCursor = data.nextCursor
                    owner.recentNetworkTime = .now()
                    postList.onNext(owner.postResponse?.data ?? [])
                    
                    // 다음 커서 세팅
                    owner.postFetchQuery.next = data.nextCursor
                    
                case .failure(let error):
                    print("포스트 조회 페이지네이션 실패")
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
