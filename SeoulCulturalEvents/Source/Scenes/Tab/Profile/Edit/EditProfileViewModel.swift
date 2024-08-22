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
    
    init(profile: ProfileModel) {
        self.profile = profile
    }
    
    private var profile: ProfileModel
    private let disposeBag = DisposeBag()
    
    struct Input {
        let nickname: ControlProperty<String>
        let profileImageData: BehaviorSubject<Data?>
        let profileSelectButtonTap: ControlEvent<Void>
        let saveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let profile: Observable<ProfileModel>
        let profileSelectButtonTap: ControlEvent<Void>
        let editProfileSuccess: Observable<ProfileModel>
        let editProfileFailure: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
        let profile = BehaviorSubject(value: profile)
        let editProfileSuccess = PublishSubject<ProfileModel>()
        let editProfileFailure = PublishSubject<String>()
        
        // MARK: - 포스트 이미지 업로드 테스트
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
        
        // 프로필 수정 통신
//        input.saveButtonTap
//            .withLatestFrom(Observable.combineLatest(input.nickname, input.profileImageData))
//            .flatMap { value in
//                let query = EditProfileQuery(nick: value.0, phoneNum: nil, birthDay: nil, profile: value.1)
//                return LSLPAPIManager.shared.callRequestWithRetry(
//                    api: .editProfile(query: query),
//                    model: ProfileModel.self
//                )
//            }
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let data):
//                    print("프로필 수정 성공")
//                    editProfileSuccess.onNext(data)
//                case .failure(let error):
//                    print("프로필 수정 실패")
//                    editProfileFailure.onNext(error.localizedDescription)
//                }
//            }
//            .disposed(by: disposeBag)
        
        return Output(
            profile: profile,
            profileSelectButtonTap: input.profileSelectButtonTap,
            editProfileSuccess: editProfileSuccess,
            editProfileFailure: editProfileFailure
        )
    }
}
