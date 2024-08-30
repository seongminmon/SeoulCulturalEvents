//
//  CommentViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel: ViewModelType {
    
    // TODO: - 댓글 수정 / 삭제
    // TODO: - 댓글 실시간 갱신
    init(postID: String, commentList: [CommentModel]) {
        self.postID = postID
        self.commentList = commentList
    }
    
    private let postID: String
    private var commentList: [CommentModel]
    private let disposeBag = DisposeBag()
    
    struct Input {
        let comment: ControlProperty<String>
        let confirmButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let commentList: BehaviorSubject<[CommentModel]>
    }
    
    func transform(input: Input) -> Output {
        
        let commentList = BehaviorSubject<[CommentModel]>(value: self.commentList)
        
        // 댓글 작성 통신
        input.confirmButtonTap
            .withLatestFrom(input.comment)
            .flatMap { content in
                let query = CommentQuery(content: content)
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: .createComment(postID: self.postID, query: query),
                    model: CommentModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("댓글 작성 성공")
                    dump(data)
                    owner.commentList.insert(data, at: 0)
                    commentList.onNext(owner.commentList)
                    
                case .failure(let error):
                    print("댓글 작성 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            commentList: commentList
        )
    }
}
