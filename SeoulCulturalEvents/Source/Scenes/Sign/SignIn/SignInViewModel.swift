//
//  SignInViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let signInTap: ControlEvent<Void>
        let signUpTap: ControlEvent<Void>
    }
    
    struct Output {
        let signInSuccess: PublishSubject<Void>
        let signInFailure: PublishSubject<String>
        let signUpTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let signInSuccess = PublishSubject<Void>()
        let signInFailure = PublishSubject<String>()
        
        // 로그인 버튼 누를 시 사용자가 입력한 이메일, 패스워드로 SignIn 통신
        input.signInTap
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText))
            .map { SignInQuery(email: $0.0, password: $0.1) }
            .flatMap { query in
                LSLPAPIManager.shared.callRequest(
                    api: .signIn(query: query),
                    model: SignInModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    dump(data)
                    // 토큰 저장
                    UserDefaultsManager.shared.signIn(data.access, data.refresh, data.id)
                    signInSuccess.onNext(())
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    signInFailure.onNext("로그인 실패")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            signInSuccess: signInSuccess,
            signInFailure: signInFailure,
            signUpTap: input.signUpTap
        )
    }
}
