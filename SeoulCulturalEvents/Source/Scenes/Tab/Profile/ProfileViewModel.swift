//
//  ProfileViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import Foundation
import RxSwift
import RxCocoa

enum UserStorage: String, CaseIterable {
    case likeCulturalEvent = "관심 행사"
    case likePost = "관심 후기"
    case myPost = "내 후기"
}

final class ProfileViewModel: ViewModelType {
    
    let sections: [SettingSection] = [
        SettingSection(model: "보관함", items: UserStorage.allCases.map { $0.rawValue } )
    ]
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewWillAppear: ControlEvent<Bool>
        let editButtonTap: ControlEvent<Void>
        let followerButtonTap: ControlEvent<Void>
        let followingButtonTap: ControlEvent<Void>
        let cellTap: ControlEvent<IndexPath>
        let withdrawAction: PublishSubject<Void>
        let newProfile: PublishSubject<ProfileModel>
    }
    
    struct Output {
        let settinglist: BehaviorSubject<[SettingSection]>
        let editButtonTap: ControlEvent<Void>
        let profile: PublishSubject<ProfileModel>
        let cellTap: PublishSubject<(IndexPath, String)>
        let withdrawTap: PublishSubject<Void>
        let withdrawActionSuccess: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let settinglist = BehaviorSubject(value: sections)
        let profile = PublishSubject<ProfileModel>()
        let cellTap = PublishSubject<(IndexPath, String)>()
        let withdrawTap = PublishSubject<Void>()
        let withdrawActionSuccess = PublishSubject<Void>()
        
        // 내 프로필 조회 통신하기
        input.viewWillAppear
            .flatMap { _ in
                LSLPAPIManager.shared.callRequestWithRetry(api: .fetchProfile, model: ProfileModel.self)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("프로필 조회 성공")
                    dump(data)
                    profile.onNext(data)
                case .failure(let error):
                    print("프로필 조회 실패")
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.cellTap
            .withLatestFrom(profile) { ($0, $1) }
            .subscribe(with: self) { owner, value in
                cellTap.onNext((value.0, value.1.id))
            }
            .disposed(by: disposeBag)
        
        // MARK: - 탈퇴 기능 막아두기
//        input.withdrawAction
//            .flatMap { LSLPAPIManager.shared.callRequestWithRetry(api: .withdraw, model: SignUpModel.self) }
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let data):
//                    print("탈퇴 성공")
//                    withdrawActionSuccess.onNext(())
//                    
//                case .failure(let error):
//                    print("탈퇴 실패")
//                    print(error.localizedDescription)
//                }
//            }
//            .disposed(by: disposeBag)
        
        // 프로필 수정 화면에서 받아온 데이터 넘겨주기
        input.newProfile
            .subscribe(with: self) { owner, value in
                profile.onNext(value)
            }
            .disposed(by: disposeBag)
        
        return Output(
            settinglist: settinglist,
            editButtonTap: input.editButtonTap,
            profile: profile,
            cellTap: cellTap,
            withdrawTap: withdrawTap,
            withdrawActionSuccess: withdrawActionSuccess
        )
    }
}
