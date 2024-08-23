//
//  DetailPostViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailPostViewModel: ViewModelType {
    
    init(postID: String) {
        self.postID = postID
    }
    
    private let postID: String
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let likeButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let post: PublishSubject<PostModel>
        let imageList: PublishSubject<[String]>
        let isLike: BehaviorSubject<Bool>
    }
    
    func transform(input: Input) -> Output {

        let post = PublishSubject<PostModel>()
        let imageList = PublishSubject<[String]>()
        let isLike = BehaviorSubject<Bool>(value: false)
        
        // MARK: - 후기 화면 데이터가 최신 상태가 아닐 수 있으므로 새롭게 통신
        // 특정 포스트 조회 통신
        input.viewDidLoad
            .withUnretained(self)
            .flatMap { _ in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: .fetchPost(postID: self.postID),
                    model: PostModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("특정 포스트 조회 통신 성공")
                    post.onNext(data)
                    imageList.onNext(data.files)
                    isLike.onNext(data.likes.contains(UserDefaultsManager.shared.userID))
                    
                case .failure(let error):
                    print("특정 포스트 조회 통신 성공")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        // 포스트 좋아요 통신
        input.likeButtonTap
            .withLatestFrom(Observable.combineLatest(post, isLike))
            .flatMap { LSLPAPIManager.shared.callRequestWithRetry(api: .postLike(postID: $0.0.postID, query: LikeModel(likeStatus: !$0.1)), model: LikeModel.self) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 좋아요 통신 성공")
                    print(data)
                    isLike.onNext(data.likeStatus)
                    
                case .failure(let error):
                    print("포스트 좋아요 통신 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
        post: post,
        imageList: imageList,
        isLike: isLike
        )
    }
}
