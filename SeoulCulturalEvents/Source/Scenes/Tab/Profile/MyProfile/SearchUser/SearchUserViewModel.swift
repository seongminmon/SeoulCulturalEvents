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
    
    private var following: [String]
    private let disposeBag = DisposeBag()
    
    init(following: [String]) {
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
        
        let userList = BehaviorSubject<[UserModel]>(value: [])
        
        // 유저 검색 통신
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
                    print("유저 검색 성공")
                    let list = owner.configureIsFollow(data.data)
                    userList.onNext(list)
                    
                case .failure(let error):
                    print("유저 검색 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        // 팔로우 / 팔로우 취소 통신
        input.followButtonTap
            .flatMap {
                if $0.isFollow {
                    // 팔로우 취소
                    return LSLPAPIManager.shared.callRequestWithRetry(
                        api: .cancelFollow(userID: $0.id),
                        model: FollowModel.self
                    )
                } else {
                    // 팔로우
                    return LSLPAPIManager.shared.callRequestWithRetry(
                        api: .follow(userID: $0.id),
                        model: FollowModel.self
                    )
                }
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    if data.followingStatus {
                        print("팔로우 성공")
                        owner.following.append(data.opponentNick)
                    } else {
                        print("팔로우 취소 성공")
                        if let index = owner.following.firstIndex(of: data.opponentNick) {
                            owner.following.remove(at: index)
                        }
                    }
                    let list = try? userList.value()
                    userList.onNext(owner.configureIsFollow(list ?? []))
                    
                case .failure(let error):
                    print("팔로우 통신 실패")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            userList: userList
        )
    }
    
    private func configureIsFollow(_ array: [UserModel]) -> [UserModel] {
        return array
            .map { user in
                var user = user
                user.isFollow = following.contains(user.nick)
                return user
            }
    }
}
