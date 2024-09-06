//
//  MyProfileViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyProfileViewModel: ViewModelType {
    
    private let storageItems: [SettingItem] = [
        SettingItem(image: .likeEvent, text: "관심 행사"),
        SettingItem(image: .likePost, text: "관심 후기"),
        SettingItem(image: .myPost, text: "내 후기"),
    ]
    
    private let settingItems: [SettingItem] = [
        SettingItem(image: .signOut, text: "로그아웃"),
        SettingItem(image: .withdraw, text: "탈퇴하기"),
        SettingItem(image: .donate, text: "후원하기"),
    ]
    private lazy var sections: [SettingSection] = [
        SettingSection(model: "보관함", items: storageItems),
        SettingSection(model: "설정", items: settingItems)
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
        let searchButtonTap: ControlEvent<Void>
        let paymentsValidationTrigger: PublishSubject<String>
    }
    
    struct Output {
        let sections: BehaviorSubject<[SettingSection]>
        let editButtonTap: ControlEvent<Void>
        let profile: PublishSubject<ProfileModel>
        let cellTap: PublishSubject<(IndexPath, String)>
        let withdrawActionSuccess: PublishSubject<Void>
        let searchButtonTap: PublishSubject<[UserModel]>
        let networkFailure: PublishSubject<String?>
    }
    
    func transform(input: Input) -> Output {
        
        let sections = BehaviorSubject(value: sections)
        let profile = PublishSubject<ProfileModel>()
        let cellTap = PublishSubject<(IndexPath, String)>()
        let withdrawActionSuccess = PublishSubject<Void>()
        let searchButtonTap = PublishSubject<[UserModel]>()
        let networkFailure = PublishSubject<String?>()
        
        // 내 프로필 조회 통신하기
        input.viewWillAppear
            .flatMap { _ in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: ProfileRouter.fetchMyProfile,
                    model: ProfileModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("프로필 조회 성공")
                    profile.onNext(data)
                case .failure(let error):
                    print("프로필 조회 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.cellTap
            .withLatestFrom(profile) { ($0, $1) }
            .subscribe(with: self) { owner, value in
                cellTap.onNext((value.0, value.1.id))
            }
            .disposed(by: disposeBag)
        
        input.withdrawAction
            .flatMap {
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: AuthRouter.withdraw,
                    model: SignUpModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    print("탈퇴 성공")
                    withdrawActionSuccess.onNext(())
                    
                case .failure(let error):
                    print("탈퇴 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 프로필 수정 화면에서 받아온 데이터 넘겨주기
        input.newProfile
            .subscribe(with: self) { owner, value in
                profile.onNext(value)
            }
            .disposed(by: disposeBag)
        
        input.searchButtonTap
            .withLatestFrom(profile)
            .subscribe(with: self) { owner, value in
                searchButtonTap.onNext(value.following)
            }
            .disposed(by: disposeBag)
        
        // 결제 영수증 검증 통신
        input.paymentsValidationTrigger
            .map { PaymentQuery(impUID: $0, postID: PortOne.postID) }
            .flatMap { query in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: PaymentRouter.paymentsValidation(query: query),
                    model: PaymentModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("결제 영수증 검증 성공")
                    print(data)
                case .failure(let error):
                    print("결제 영수증 검증 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 결제 내역 리스트 통신 (출력 확인)
        LSLPAPIManager.shared.callRequestWithRetry(
            api: PaymentRouter.fetchPayments,
            model: PaymentList.self
        )
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let data):
                print("결제 내역 리스트 성공")
                print(data)
            case .failure(let error):
                print("결제 내역 리스트 실패")
                networkFailure.onNext(error.errorDescription)
            }
        }
        .disposed(by: disposeBag)
        
        return Output(
            sections: sections,
            editButtonTap: input.editButtonTap,
            profile: profile,
            cellTap: cellTap,
            withdrawActionSuccess: withdrawActionSuccess,
            searchButtonTap: searchButtonTap,
            networkFailure: networkFailure
        )
    }
}
