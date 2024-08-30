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
    
    private let culturalEvent: CulturalEvent
    private var postID: String?
    private let disposeBag = DisposeBag()
    
    init(culturalEvent: CulturalEvent) {
        self.culturalEvent = culturalEvent
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let likeButtonTap: ControlEvent<Void>
        let showMapButtonTap: ControlEvent<Void>
        let reserveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let data: Observable<CulturalEvent>
        let likeFlag: Observable<Bool>
        let networkFailure: Observable<String>
        let showMapButtonTap: PublishSubject<(lat: Double, lon: Double)>
        let reserveLink: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
        let data = BehaviorSubject<CulturalEvent>(value: culturalEvent)
        let likeFlag = BehaviorSubject<Bool>(value: postID == nil)
        let networkFailure = PublishSubject<String>()
        let showMapButtonTap = PublishSubject<(lat: Double, lon: Double)>()
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
                let productID = self.culturalEvent.title + UserDefaultsManager.userID
                let query = PostFetchQuery(productID: productID)
                return LSLPAPIManager.shared.callRequestWithRetry(api: .fetchPostList(query: query), model: PostModelList.self)
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
        
        // postID가 nil이면 업로드하기
        input.likeButtonTap
            .withUnretained(self)
            .compactMap { _ -> Void? in
                return self.postID == nil ? () : nil
            }
            .flatMap { _ in
                let content = self.culturalEvent.toString()
                let productID = self.culturalEvent.title + UserDefaultsManager.userID
                let query = PostQuery(title: self.culturalEvent.title, productID: productID, content: content, files: [])
                return LSLPAPIManager.shared.callRequestWithRetry(api: .createPost(query: query), model: PostModel.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 업로드 성공")
                    owner.postID = data.postID
                    likeFlag.onNext(true)
                    
                case .failure(let error):
                    print("포스트 업로드 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        // postID를 갖고 있으면 삭제하기
        input.likeButtonTap
            .withUnretained(self)
            .compactMap { _ in self.postID }
            .flatMap { value in
                return LSLPAPIManager.shared.callRequestWithRetry(api: .deletePost(postID: value))
            }
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
            .disposed(by: disposeBag)
        
        input.showMapButtonTap
            .subscribe(with: self) { owner, _ in
                showMapButtonTap.onNext((owner.culturalEvent.lat, owner.culturalEvent.lon))
            }
            .disposed(by: disposeBag)
        
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
            showMapButtonTap: showMapButtonTap,
            reserveLink: reserveLink
        )
    }
}
