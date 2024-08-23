//
//  ProfileViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct SettingSection {
    var header: String
    var items: [Item]
}
// TODO: - AnimatableSectionModel로 바꿔보기
extension SettingSection: AnimatableSectionModelType {
    typealias Item = String
    
    init(original: SettingSection, items: [String]) {
        self = original
        self.items = items
    }
    
    var identity: String {
        return header
    }
}

final class ProfileViewModel: ViewModelType {
    
    private enum SettingCellData: String, CaseIterable {
        case likeCulturalEvent = "관심 행사"
        case likePost = "관심 포스트"
        case myPost = "내가 쓴 포스트"
        case alarm = "내가 쓴 코멘트"
        case delete = "탈퇴하기"
    }
    
    let sectionData = [SettingSection(header: "보관함", items: SettingCellData.allCases.map { $0.rawValue })]
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
        let list: BehaviorSubject<[SettingSection]>
        let editButtonTap: ControlEvent<Void>
        let profile: PublishSubject<ProfileModel>
        let withdrawTap: PublishSubject<Void>
        let withdrawActionSuccess: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let list = BehaviorSubject(value: sectionData)
        let profile = PublishSubject<ProfileModel>()
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
                    profile.onNext(data)
                case .failure(let error):
                    print("프로필 조회 실패")
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.cellTap
            .subscribe(with: self) { owner, indexPath in
                switch indexPath.row {
                case 4:
                    withdrawTap.onNext(())
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        input.withdrawAction
            .flatMap { LSLPAPIManager.shared.callRequestWithRetry(api: .withdraw, model: SignUpModel.self) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("탈퇴 성공")
                    withdrawActionSuccess.onNext(())
                    
                case .failure(let error):
                    print("탈퇴 실패")
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 프로필 수정 화면에서 받아온 데이터 넘겨주기
        input.newProfile
            .subscribe(with: self) { owner, value in
                profile.onNext(value)
            }
            .disposed(by: disposeBag)
        
        return Output(
            list: list,
            editButtonTap: input.editButtonTap,
            profile: profile,
            withdrawTap: withdrawTap,
            withdrawActionSuccess: withdrawActionSuccess
        )
    }
}
