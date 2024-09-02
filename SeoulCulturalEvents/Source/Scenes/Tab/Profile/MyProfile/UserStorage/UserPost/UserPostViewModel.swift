//
//  UserPostViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import Foundation
import RxSwift
import RxCocoa

final class UserPostViewModel: ViewModelType {
    
    private let userID: String
    private var postResponse: PostModelList?
    private let disposeBag = DisposeBag()
    
    init(userID: String) {
        self.userID = userID
    }
    
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
        
        // 내 포스트 조회 (productID: 후기)
        let query = PostFetchQuery(productID: ProductID.post)
        LSLPAPIManager.shared.callRequestWithRetry(
            api: PostRouter.fetchUserPostList(userID: userID, query: query),
            model: PostModelList.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let data):
                print("내 포스트 조회 성공")
                owner.postResponse = data
                postList.onNext(data.data)
                
            case .failure(let error):
                print("내 포스트 조회 실패")
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
