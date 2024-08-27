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
    
    init(userID: String) {
        self.userID = userID
    }
    
    private let userID: String
    private let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let profile: PublishSubject<ProfileModel>
    }
    
    func transform(input: Input) -> Output {
        
        let profile = PublishSubject<ProfileModel>()
        
        // 다른 유저 프로필 조회 통신
        LSLPAPIManager.shared.callRequestWithRetry(
            api: .fetchProfile(userID: userID),
            model: ProfileModel.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let data):
                print("다른 유저 프로필 조회 성공")
                dump(data)
                profile.onNext(data)
                
            case .failure(let error):
                print("다른 유저 프로필 조회 실패")
                print(error)
            }
        }
        .disposed(by: disposeBag)
        
        return Output(
            profile: profile
        )
    }
}
