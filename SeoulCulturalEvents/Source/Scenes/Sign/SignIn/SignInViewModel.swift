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
    
    struct Input {
        let emailText: ControlProperty<String?>
        let passwordText: ControlProperty<String?>
        let signInTap: ControlEvent<Void>
        let signUpTap: ControlEvent<Void>
    }
    
    struct Output {
        let signUpTap: ControlEvent<Void>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        return Output(
            signUpTap: input.signUpTap
        )
    }
}
