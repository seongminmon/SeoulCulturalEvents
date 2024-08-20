//
//  EditProfileViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import Kingfisher

final class EditProfileViewModel: ViewModelType {
    
    struct Input {
        let nickname: ControlProperty<String>
        let profileImageData: BehaviorSubject<Data?>
        let profileSelectButtonTap: ControlEvent<Void>
        let saveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let profile: Observable<ProfileModel>
        let profileSelectButtonTap: ControlEvent<Void>
        let editProfileSuccess: Observable<Void>
        let editProfileFailure: Observable<String>
    }
    
    init(profile: ProfileModel) {
        self.profile = profile
    }
    
    private var profile: ProfileModel
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let profile = BehaviorSubject(value: profile)
        let editProfileSuccess = PublishSubject<Void>()
        let editProfileFailure = PublishSubject<String>()
        
        input.saveButtonTap
            .withLatestFrom(Observable.combineLatest(input.nickname, input.profileImageData))
            .flatMap { value in
                let query = EditProfileQuery(nick: value.0, phoneNum: nil, birthDay: nil, profile: value.1)
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: .editProfile(query: query),
                    model: ProfileModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("프로필 수정 성공")
                    dump(data)
                    editProfileSuccess.onNext(())
                case .failure(let error):
                    print("프로필 수정 실패")
                    print(error)
                    editProfileFailure.onNext(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            profile: profile,
            profileSelectButtonTap: input.profileSelectButtonTap,
            editProfileSuccess: editProfileSuccess,
            editProfileFailure: editProfileFailure
        )
    }
}