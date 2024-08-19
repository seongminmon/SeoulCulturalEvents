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
    }
    
    struct Output {
        let data: Observable<CulturalEvent>
        let likeFlag: Observable<Bool>
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
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                data.onNext(owner.culturalEvent)
                owner.likeFlag = UserDefaultsManager.shared.likes.contains(owner.culturalEvent.title)
                likeFlag.onNext(owner.likeFlag)
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .subscribe(with: self) { owner, _ in
                // TODO: - 포스트 업로드, 삭제
                if owner.likeFlag {
                    // 삭제
                    
                } else {
                    // 업로드
                    let content = owner.culturalEvent.toString()
                    let query = PostQuery(title: owner.culturalEvent.title, content: content, content1: nil, content2: nil, content3: nil, content4: nil, content5: nil, productID: ProductID.cultural, files: [])
                    LSLPAPIManager.shared.callRequestWithRetry(api: .createPost(query: query), model: PostModel.self)
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success(let data):
                                dump(data)
                                UserDefaultsManager.shared.likes.append(owner.culturalEvent.title)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                }
                owner.likeFlag.toggle()
                likeFlag.onNext(owner.likeFlag)
            }
            .disposed(by: disposeBag)
        
        return Output(
            data: data,
            likeFlag: likeFlag
        )
    }
}
