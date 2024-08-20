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
    
    init(culturalEvent: CulturalEvent) {
        self.culturalEvent = culturalEvent
    }
    
    private let culturalEvent: CulturalEvent
    private var likeFlag: Bool = false
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let data = BehaviorSubject<CulturalEvent>(value: culturalEvent)
        let likeFlag = BehaviorSubject<Bool>(value: likeFlag)
        let networkFailure = PublishSubject<String>()
        let reserveLink = PublishSubject<String>()
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                data.onNext(owner.culturalEvent)
                owner.likeFlag = UserDefaultsManager.shared.likeTitles.contains(owner.culturalEvent.title)
                likeFlag.onNext(owner.likeFlag)
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .subscribe(with: self) { owner, _ in
                if owner.likeFlag {
                    // 포스트 삭제
                    guard let index = UserDefaultsManager.shared.likeTitles.firstIndex(of: owner.culturalEvent.title) else { return }
                    let postID = UserDefaultsManager.shared.likeIDs[index]
                    LSLPAPIManager.shared.callRequestWithRetry(api: .deletePost(postID: postID))
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success(let data):
                                print("포스트 삭제 성공")
                                dump(data)
                                UserDefaultsManager.shared.likeTitles.remove(at: index)
                                UserDefaultsManager.shared.likeIDs.remove(at: index)
                                owner.likeFlag = false
                                likeFlag.onNext(owner.likeFlag)
                            case .failure(let error):
                                print("포스트 삭제 실패")
                                print(error.localizedDescription)
                                networkFailure.onNext(error.localizedDescription)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                    
                } else {
                    // 포스트 업로드
                    let content = owner.culturalEvent.toString()
                    let query = PostQuery(title: owner.culturalEvent.title, content: content, content1: nil, content2: nil, content3: nil, content4: nil, content5: nil, productID: ProductID.cultural, files: [])
                    LSLPAPIManager.shared.callRequestWithRetry(api: .createPost(query: query), model: PostModel.self)
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success(let data):
                                print("포스트 업로드 성공")
                                dump(data)
                                UserDefaultsManager.shared.likeTitles.append(owner.culturalEvent.title)
                                UserDefaultsManager.shared.likeIDs.append(data.postID)
                                owner.likeFlag = true
                                likeFlag.onNext(owner.likeFlag)
                            case .failure(let error):
                                print("포스트 업로드 실패")
                                print(error.localizedDescription)
                                networkFailure.onNext(error.localizedDescription)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                }
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
            reserveLink: reserveLink
        )
    }
}
