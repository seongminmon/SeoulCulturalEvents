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
    
    init(commentList: [CommentModel]) {
        self.commentList = commentList
    }
    
    private let commentList: [CommentModel]
    private let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let commentList: BehaviorSubject<[CommentModel]>
    }
    
    func transform(input: Input) -> Output {
        
        let commentList = BehaviorSubject<[CommentModel]>(value: self.commentList)
        
        
        
        return Output(
        commentList: commentList
        )
    }
}
