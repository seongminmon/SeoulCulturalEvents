//
//  PostViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostViewModel: ViewModelType {
    
    private var recentNetworkTime: DispatchTime?
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let cellTap: ControlEvent<PostModel>
        let refreshEvent: ControlEvent<Void>
    }
    
    struct Output {
        let postList: BehaviorSubject<[PostModel]>
        let cellTap: ControlEvent<PostModel>
        let remainTime: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let postList = BehaviorSubject<[PostModel]>(value: [])
        let remainTime = PublishSubject<Void>()
        
        // 포스트 조회 통신
        Observable.merge(input.viewDidLoad, input.refreshEvent.asObservable())
            .flatMap { () -> Single<Result<PostModelList, LSLPError>> in
                // 1분이 안 지났으면 통신 X
                if let recentNetworkTime = self.recentNetworkTime, 
                    recentNetworkTime + 60 > .now() {
                    remainTime.onNext(())
                    return Single.just(.failure(LSLPError.unknown))
                }
                let query = PostFetchQuery(next: nil, productID: ProductID.post)
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: .fetchPostList(query: query),
                    model: PostModelList.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 조회 성공")
                    owner.recentNetworkTime = .now()
                    postList.onNext(data.data)
                    
                case .failure(let error):
                    print("포스트 조회 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            postList: postList,
            cellTap: input.cellTap,
            remainTime: remainTime
        )
    }
}

// MARK: - 포스트 이미지 업로드 테스트
/*
input.saveButtonTap
    .withLatestFrom(Observable.combineLatest(input.nickname, input.profileImageData))
    .flatMap { value in
        let files: [Data?] = [value.1, value.1, value.1, value.1, value.1]
        print(files)
        return LSLPAPIManager.shared.callRequestWithRetry(api: .postImageFiles(files: files), model: PostImageModel.self)
    }
    .subscribe(with: self) { owner, result in
        switch result {
        case .success(let data):
            print("포스트 이미지 업로드 성공")
            dump(data)
        case .failure(let error):
            print("포스트 이미지 업로드 실패")
        }
    }
    .disposed(by: disposeBag)
 */
