//
//  SearchUserViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchUserViewModel: ViewModelType {
    
    private var following: [UserModel]
    private let disposeBag = DisposeBag()
    
    init(following: [UserModel]) {
        self.following = following
    }
    
    struct Input {
        let searchText: ControlProperty<String>
        let searchButtonTap: ControlEvent<Void>
        let followButtonTap: PublishSubject<UserModel>
    }
    
    struct Output {
        let userList: BehaviorSubject<[UserModel]>
    }
    
    func transform(input: Input) -> Output {
        
        // TODO: - 팔로우 초기 상태 셀에 전달
        // TODO: - 팔로우 / 취소 기능 구현
        
        let userList = BehaviorSubject<[UserModel]>(value: [])
        
        // 다른 유저 검색 통신
        input.searchButtonTap
            .withLatestFrom(input.searchText)
            .flatMap { nick in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: .searchUser(nick: nick),
                    model: SearchUserModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("유저 검색 통신 성공")
                    userList.onNext(data.data)
                    
                case .failure(let error):
                    print("유저 검색 통신 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
  
        // 팔로우 통신
//        input.followButtonTap
//            .flatMap {
//                LSLPAPIManager.shared.callRequestWithRetry(
//                    api: .follow(userID: $0.id),
//                    model: FollowModel.self
//                )
//            }
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let data):
//                    print("팔로우 통신 성공")
//                    print(data)
//                case .failure(let error):
//                    print("팔로우 통신 실패")
//                    print(error)
//                }
//            }
//            .disposed(by: disposeBag)
        
        // 팔로우 취소 통신
//        input.followButtonTap
//            .flatMap {
//                LSLPAPIManager.shared.callRequestWithRetry(
//                    api: .cancelFollow(userID: $0.id),
//                    model: FollowModel.self
//                )
//            }
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let data):
//                    print("팔로우 통신 성공")
//                    print(data)
//                case .failure(let error):
//                    print("팔로우 통신 실패")
//                    print(error)
//                }
//            }
//            .disposed(by: disposeBag)
        
        return Output(
            userList: userList
        )
    }
}
