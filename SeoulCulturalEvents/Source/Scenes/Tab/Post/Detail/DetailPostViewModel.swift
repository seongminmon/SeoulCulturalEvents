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
    
    private let postID: String
    private let disposeBag = DisposeBag()
    
    init(postID: String) {
        self.postID = postID
    }

    struct Input {
        let viewDidLoad: Observable<Void>
        let likeButtonTap: ControlEvent<Void>
        let commentButtonTap: ControlEvent<Void>
        let userInfoButtonTap: ControlEvent<Void>
        let settingButtonTap: ControlEvent<Void>
        let editAction: PublishSubject<Void>
        let deleteAction: PublishSubject<Void>
        let networkTrigger: Observable<Void>
    }
    
    struct Output {
        let navigationTitle: PublishSubject<String?>
        let post: PublishSubject<PostModel>
        let imageList: PublishSubject<[String]>
        let isLike: PublishSubject<Bool>
        let commentButtonTap: PublishSubject<(String, [CommentModel])>
        let userInfoButtonTap: PublishSubject<String>
        let settingButtonTap: ControlEvent<Void>
        let postDeleteSuccess: PublishSubject<Void>
        let editPost: PublishSubject<(PostModel)>
        let notMyPost: PublishSubject<Void>
        let networkFailure: PublishSubject<String?>
    }
    
    func transform(input: Input) -> Output {

        let navigationTitle = PublishSubject<String?>()
        let post = PublishSubject<PostModel>()
        let imageList = PublishSubject<[String]>()
        let isLike = PublishSubject<Bool>()
        let commentButtonTap = PublishSubject<(String, [CommentModel])>()
        let userInfoButtonTap = PublishSubject<String>()
        let postDeleteSuccess = PublishSubject<Void>()
        let editPost = PublishSubject<(PostModel)>()
        let notMyPost = PublishSubject<Void>()
        let networkFailure = PublishSubject<String?>()
        
        // MARK: - 후기 화면 데이터가 최신 상태가 아닐 수 있으므로 새롭게 통신
        // 특정 포스트 조회 통신
        Observable.merge(input.viewDidLoad, input.networkTrigger)
            .withUnretained(self)
            .flatMap { _ in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: PostRouter.fetchPost(postID: self.postID),
                    model: PostModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("특정 포스트 조회 통신 성공")
                    post.onNext(data)
                    navigationTitle.onNext(data.title)
                    imageList.onNext(data.files)
                    isLike.onNext(data.likes.contains(UserDefaultsManager.userID))
                    
                case .failure(let error):
                    print("특정 포스트 조회 통신 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 포스트 좋아요 통신
        input.likeButtonTap
            .withLatestFrom(Observable.combineLatest(post, isLike))
            .flatMap { LSLPAPIManager.shared.callRequestWithRetry(api: LikeRouter.postLike(postID: $0.0.postID, query: LikeModel(likeStatus: !$0.1)), model: LikeModel.self) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 좋아요 통신 성공")
                    isLike.onNext(data.likeStatus)
                    
                case .failure(let error):
                    print("포스트 좋아요 통신 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.commentButtonTap
            .withLatestFrom(post)
            .subscribe(with: self) { owner, value in
                commentButtonTap.onNext((value.postID, value.comments))
            }
            .disposed(by: disposeBag)
        
        input.userInfoButtonTap
            .withLatestFrom(post)
            .subscribe(with: self) { owner, value in
                userInfoButtonTap.onNext(value.creator.id)
            }
            .disposed(by: disposeBag)
  
        // 포스트 수정
        input.editAction
            .withLatestFrom(post)
            .subscribe(with: self) { owner, value in
                if value.creator.id == UserDefaultsManager.userID {
                    editPost.onNext(value)
                } else {
                    notMyPost.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        // 포스트 삭제
        input.deleteAction
            .withLatestFrom(post)
            .compactMap { value in
                if value.creator.id == UserDefaultsManager.userID {
                    return value
                } else {
                    notMyPost.onNext(())
                    return nil
                }
            }
            .flatMap { post in
                LSLPAPIManager.shared.callRequestWithRetry(api: PostRouter.deletePost(postID: post.postID))
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    print("포스트 삭제 성공")
                    postDeleteSuccess.onNext(())
                    
                case .failure(let error):
                    print("포스트 삭제 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            navigationTitle: navigationTitle,
            post: post,
            imageList: imageList,
            isLike: isLike,
            commentButtonTap: commentButtonTap,
            userInfoButtonTap: userInfoButtonTap,
            settingButtonTap: input.settingButtonTap,
            postDeleteSuccess: postDeleteSuccess,
            editPost: editPost,
            notMyPost: notMyPost,
            networkFailure: networkFailure
        )
    }
}
