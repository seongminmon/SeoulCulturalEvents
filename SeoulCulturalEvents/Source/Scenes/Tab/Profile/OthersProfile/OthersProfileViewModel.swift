//
//  OthersProfileViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/27/24.
//

import Foundation
import RxSwift
import RxCocoa

final class OthersProfileViewModel: ViewModelType {
    
    private let userID: String
    private let disposeBag = DisposeBag()
    
    init(userID: String) {
        self.userID = userID
    }
    
    struct Input {
        let additionalButtonTap: ControlEvent<Void>
        let cellTap: ControlEvent<PostModel>
    }
    
    struct Output {
        let profile: PublishSubject<ProfileModel>
        let isFollow: PublishSubject<Bool>
        let postList: BehaviorSubject<[PostModel]>
        let cellTap: ControlEvent<PostModel>
        let networkFailure: PublishSubject<String?>
    }
    
    func transform(input: Input) -> Output {
        
        let profile = PublishSubject<ProfileModel>()
        let isFollow = PublishSubject<Bool>()
        let postList = BehaviorSubject<[PostModel]>(value: [])
        let networkFailure = PublishSubject<String?>()
        
        // 다른 유저 프로필 조회 통신
        LSLPAPIManager.shared.callRequestWithRetry(
            api: ProfileRouter.fetchProfile(userID: userID),
            model: ProfileModel.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let data):
                print("다른 유저 프로필 조회 성공")
                profile.onNext(data)
                
            case .failure(let error):
                print("다른 유저 프로필 조회 실패")
                print(error)
            }
        }
        .disposed(by: disposeBag)
        
        // 팔로우 초기 상태
        profile
            .map { $0.followers.map { $0.id } }
            .map { $0.contains(UserDefaultsManager.userID) }
            .bind(to: isFollow)
            .disposed(by: disposeBag)
        
        // 팔로우
        input.additionalButtonTap
            .withLatestFrom(isFollow)
            .compactMap { value -> Void? in
                return value ? nil : ()
            }
            .withLatestFrom(profile)
            .map { $0.id }
            .flatMap { userID in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: FollowRouter.follow(userID: userID),
                    model: FollowModel.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("팔로우 성공")
                    isFollow.onNext(data.followingStatus)
                    
                case .failure(let error):
                    print("팔로우 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 팔로우 취소
        input.additionalButtonTap
            .withLatestFrom(isFollow)
            .compactMap { value -> Void? in
                return value ? () : nil
            }
            .withLatestFrom(profile)
            .map { $0.id }
            .flatMap { userID in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: FollowRouter.cancelFollow(userID: userID),
                    model: FollowModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("팔로우 취소 성공")
                    isFollow.onNext(data.followingStatus)
                    
                case .failure(let error):
                    print("팔로우 취소 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 유저별 작성한 포스트 조회 통신
        let query = PostFetchQuery(productID: ProductID.post)
        LSLPAPIManager.shared.callRequestWithRetry(
            api: PostRouter.fetchUserPostList(userID: userID, query: query),
            model: PostModelList.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let data):
                print("유저별 포스트 조회 성공")
                postList.onNext(data.data)
                
            case .failure(let error):
                print("유저별 포스트 조회 실패")
                networkFailure.onNext(error.errorDescription)
            }
        }
        .disposed(by: disposeBag)
        
        return Output(
            profile: profile,
            isFollow: isFollow,
            postList: postList, 
            cellTap: input.cellTap,
            networkFailure: networkFailure
        )
    }
}
