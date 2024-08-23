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
    
    init(post: PostModel) {
        self.post = post
    }
    
    private let post: PostModel
    private let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let post: BehaviorSubject<PostModel>
        let likeState: BehaviorSubject<Bool>
        let imageList: BehaviorSubject<[String]>
    }
    
    func transform(input: Input) -> Output {
        
        let post = BehaviorSubject<PostModel>(value: post)
        let likeState = BehaviorSubject<Bool>(value: self.post.likes.contains(UserDefaultsManager.shared.userID))
        let imageList = BehaviorSubject<[String]>(value: self.post.files)
        
        return Output(
        post: post,
        likeState: likeState,
        imageList: imageList
        )
    }
}
