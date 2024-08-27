//
//  LikePostViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import Foundation

import RxSwift
import RxCocoa

final class LikePostViewModel: ViewModelType {
    
    init(userID: String) {
        self.userID = userID
    }
    
    private let userID: String
    private var postResponse: PostModelList?
    private let disposeBag = DisposeBag()
    
    struct Input {
        let cellTap: ControlEvent<PostModel>
    }
    
    struct Output {
        let postList: BehaviorSubject<[PostModel]>
        let cellTap: ControlEvent<PostModel>
        let networkFailure: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        
        let postList = BehaviorSubject<[PostModel]>(value: [])
        let networkFailure = PublishSubject<String>()
        
        // 좋아요한 포스트 조회
        let query = PostFetchQuery(productID: ProductID.post)
        LSLPAPIManager.shared.callRequestWithRetry(
            api: .fetchLikePostList(query: query),
            model: PostModelList.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let data):
                print("좋아요한 포스트 조회 성공")
                owner.postResponse = data
                postList.onNext(data.data)
                
            case .failure(let error):
                print("좋아요한 포스트 조회 실패")
                print(error)
                networkFailure.onNext(error.localizedDescription)
            }
        }
        .disposed(by: disposeBag)
        
        return Output(
            postList: postList,
            cellTap: input.cellTap,
            networkFailure: networkFailure
        )
    }
}
