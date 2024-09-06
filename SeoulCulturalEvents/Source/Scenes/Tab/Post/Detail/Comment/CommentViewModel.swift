//
//  CommentViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel {
    
    private let postID: String
    private var commentList: [CommentModel]
    private let disposeBag = DisposeBag()
    
    init(postID: String, commentList: [CommentModel]) {
        self.postID = postID
        self.commentList = commentList
    }
    
    struct Input {
        let comment: ControlProperty<String>
        let confirmButtonTap: ControlEvent<Void>
        let editAction: PublishSubject<(CommentModel, String)>
        let deleteAction: PublishSubject<CommentModel>
    }
    
    struct Output {
        let commentList: BehaviorSubject<[CommentModel]>
        let commentCreate: PublishSubject<Void>
        let notMyComment: PublishSubject<Void>
        let networkFailure: PublishSubject<String?>
    }
    
    func transform(input: Input) -> Output {
        
        let commentNetwork = BehaviorSubject<Void>(value: ())
        let commentList = BehaviorSubject<[CommentModel]>(value: self.commentList)
        let commentCreate = PublishSubject<Void>()
        let notMyComment = PublishSubject<Void>()
        let networkFailure = PublishSubject<String?>()
        
        // 특정 포스트 조회 -> 댓글 업데이트
        commentNetwork
            .flatMap { [weak self] _ in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: PostRouter.fetchPost(postID: self?.postID ?? ""),
                    model: PostModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("댓글 갱신 성공")
                    commentList.onNext(data.comments)
                case .failure(let error):
                    print("댓글 갱신 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 댓글 작성 통신
        input.confirmButtonTap
            .withLatestFrom(input.comment)
            .flatMap { content in
                let query = CommentQuery(content: content)
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: CommentRouter.createComment(postID: self.postID, query: query),
                    model: CommentModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("댓글 작성 성공")
                    commentNetwork.onNext(())
                    commentCreate.onNext(())
                    
                case .failure(let error):
                    print("댓글 작성 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 댓글 수정
        input.editAction
            .compactMap { value in
                let (comment, newText) = (value.0, value.1)
                if comment.creator.id == UserDefaultsManager.userID {
                    return value
                } else {
                    notMyComment.onNext(())
                    return nil
                }
            }
            .flatMap { [weak self] value in
                let (comment, newText) = (value.0, value.1)
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: CommentRouter.editComment(postID: self?.postID ?? "", commentID: comment.id, query: CommentQuery(content: newText)),
                    model: CommentModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    print("댓글 수정 성공")
                    commentNetwork.onNext(())
                    
                case .failure(let error):
                    print("댓글 수정 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 댓글 삭제
        input.deleteAction
            .compactMap { comment in
                if comment.creator.id == UserDefaultsManager.userID {
                    return comment
                } else {
                    notMyComment.onNext(())
                    return nil
                }
            }
            .flatMap { [weak self] comment in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: CommentRouter.deleteComment(postID: self?.postID ?? "", commentID: comment.id)
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    print("댓글 삭제 성공")
                    commentNetwork.onNext(())
                    
                case .failure(let error):
                    print("댓글 삭제 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            commentList: commentList,
            commentCreate: commentCreate,
            notMyComment: notMyComment,
            networkFailure: networkFailure
        )
    }
}
