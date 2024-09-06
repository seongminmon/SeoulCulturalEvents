//
//  SignUpViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let closeButtonTap: ControlEvent<Void>
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let nicknameText: ControlProperty<String>
        let signUpTap: ControlEvent<Void>
    }
    
    struct Output {
        let closeButtonTap: ControlEvent<Void>
        let signInSuccess: PublishSubject<Void>
        let signUpFailure: PublishSubject<String?>
    }
    
    func transform(input: Input) -> Output {
        
        let signUpSuccess = PublishSubject<Void>()
        let signUpFailure = PublishSubject<String?>()
        let signInSuccess = PublishSubject<Void>()
        
        // 가입하기 버튼 누를 시 사용자가 입력한 이메일, 패스워드, 닉네임으로 회원가입 통신
        input.signUpTap
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(
                input.emailText,
                input.passwordText,
                input.nicknameText
            ))
            .map { SignUpQuery(email: $0.0, password: $0.1, nick: $0.2) }
            .flatMap { query -> Single<(Result<SignUpModel, LSLPError>, String)> in
                let result = LSLPAPIManager.shared.callRequest(
                    api: AuthRouter.signUp(query: query),
                    model: SignUpModel.self
                )
                return result.map { ($0, query.password) }
            }
            .flatMap { result, password in
                switch result {
                case .success(let data):
                    print("회원 가입 성공")
                    // 회원 가입 성공 시 로그인까지 처리
                    let query = SignInQuery(email: data.email, password: password)
                    return LSLPAPIManager.shared.callRequest(
                        api: AuthRouter.signIn(query: query),
                        model: SignInModel.self
                    )
                case .failure(let error):
                    print("회원 가입 실패")
                    signUpFailure.onNext(error.errorDescription)
                    return Single.just(.failure(error))
                }
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("로그인 성공")
                    // 토큰 저장
                    UserDefaultsManager.signIn(data.access, data.refresh, data.id)
                    // 로그인까지 성공하면 성공
                    signInSuccess.onNext(())
                    
                case .failure(let error):
                    print("로그인 실패")
                    signUpFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            closeButtonTap: input.closeButtonTap,
            signInSuccess: signInSuccess,
            signUpFailure: signUpFailure
        )
    }
}
