//
//  CulturalEventViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CulturalEventViewModel: ViewModelType {
    
    init(culturalEvent: CulturalEvent) {
        self.culturalEvent = culturalEvent
    }
    
    private let culturalEvent: CulturalEvent
    private var postID: String?
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let likeButtonTap: ControlEvent<Void>
        let reserveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let data: Observable<CulturalEvent>
        let likeFlag: Observable<Bool>
        let networkFailure: Observable<String>
        let reserveLink: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
        let data = BehaviorSubject<CulturalEvent>(value: culturalEvent)
        let likeFlag = BehaviorSubject<Bool>(value: postID == nil)
        let networkFailure = PublishSubject<String>()
        let reserveLink = PublishSubject<String>()
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                data.onNext(owner.culturalEvent)
            }
            .disposed(by: disposeBag)
        
        // 포스트 조회 통신
        input.viewDidLoad
            .withUnretained(self)
            .flatMap { _ in
                let productID = self.culturalEvent.title + UserDefaultsManager.shared.userID
                let query = PostFetchQuery(productID: productID)
                return LSLPAPIManager.shared.callRequestWithRetry(api: .fetchPost(query: query), model: PostModelList.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 조회 성공")
                    owner.postID = data.data.first?.postID
                    likeFlag.onNext(owner.postID != nil)
                    
                case .failure(let error):
                    print("포스트 조회 실패")
                    print(error.errorDescription ?? "포스트 조회 실패")
                }
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .subscribe(with: self) { owner, _ in
                if let postID = owner.postID {
                    // postID를 갖고 있으면 삭제하기
                    LSLPAPIManager.shared.callRequestWithRetry(api: .deletePost(postID: postID))
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success:
                                print("포스트 삭제 성공")
                                owner.postID = nil
                                likeFlag.onNext(false)
                                
                            case .failure(let error):
                                print("포스트 삭제 실패")
                                print(error)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                    
                } else {
                    // postID가 nil이면 업로드하기
                    let content = owner.culturalEvent.toString()
                    let productID = owner.culturalEvent.title + UserDefaultsManager.shared.userID
                    let query = PostQuery(title: owner.culturalEvent.title, productID: productID, content: content, files: [])
                    LSLPAPIManager.shared.callRequestWithRetry(api: .createPost(query: query), model: PostModel.self)
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success(let data):
                                print("포스트 업로드 성공")
                                dump(data)
                                owner.postID = data.postID
                                likeFlag.onNext(true)
                                
                            case .failure(let error):
                                print("포스트 업로드 실패")
                                print(error)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        // TODO: - 업로드, 삭제 flatMap으로 처리해보기 (삭제와 업로드가 동시에 되는 문제 해결하면 가능)
        /*
         // postID가 nil이면 업로드하기
 //        input.likeButtonTap
 //            .withUnretained(self)
 //            .map { _ -> Void? in
 //                if self.postID == nil {
 //                    return ()
 //                } else {
 //                    return nil
 //                }
 //            }
 //            .flatMap {  _ in
 //                let content = self.culturalEvent.toString()
 //                let productID = self.culturalEvent.title + UserDefaultsManager.shared.userID
 //                let query = PostQuery(title: self.culturalEvent.title, productID: productID, content: content, files: [])
 //                return LSLPAPIManager.shared.callRequestWithRetry(api: .createPost(query: query), model: PostModel.self)
 //            }
 //            .subscribe(with: self) { owner, result in
 //                switch result {
 //                case .success(let data):
 //                    print("포스트 업로드 성공")
 //                    owner.postID = data.postID
 //                    likeFlag.onNext(true)
 //
 //                case .failure(let error):
 //                    print("포스트 업로드 실패")
 //                    print(error)
 //                }
 //            }
 //            .disposed(by: disposeBag)
         
         // postID를 갖고 있으면 삭제하기
 //        input.likeButtonTap
 //            .compactMap { self.postID }
 //            .flatMap { value in
 //                return LSLPAPIManager.shared.callRequestWithRetry(api: .deletePost(postID: value))
 //            }
 //            .subscribe(with: self) { owner, result in
 //                switch result {
 //                case .success:
 //                    print("포스트 삭제 성공")
 //                    owner.postID = nil
 //                    likeFlag.onNext(false)
 //
 //                case .failure(let error):
 //                    print("포스트 삭제 실패")
 //                    print(error)
 //                }
 //            }
 //            .disposed(by: disposeBag)
         */

        input.reserveButtonTap
            .subscribe(with: self) { owner, _ in
                let link = owner.culturalEvent.link
                reserveLink.onNext(link)
            }
            .disposed(by: disposeBag)
        
        return Output(
            data: data,
            likeFlag: likeFlag,
            networkFailure: networkFailure,
            reserveLink: reserveLink
        )
    }
}
