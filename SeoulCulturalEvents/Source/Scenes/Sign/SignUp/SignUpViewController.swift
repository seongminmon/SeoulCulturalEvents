//
//  SignUpViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class SignUpViewController: BaseViewController {
    
    private let closeButton = UIBarButtonItem(title: "닫기")
    private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요").then {
        $0.isSecureTextEntry = true
    }
    private let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    private let signUpButton = PointButton(title: "가입하기")
    
    private let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = SignUpViewModel.Input(
            closeButtonTap: closeButton.rx.tap,
            emailText: emailTextField.rx.text.orEmpty,
            passwordText: passwordTextField.rx.text.orEmpty,
            nicknameText: nicknameTextField.rx.text.orEmpty,
            signUpTap: signUpButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.closeButtonTap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.signInSuccess
            .bind(with: self) { owner, _ in
                SceneDelegate.changeWindow(TabBarController())
            }
            .disposed(by: disposeBag)
        
        output.signUpFailure
            .bind(with: self) { owner, value in
                owner.showToast(value)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "회원가입"
        navigationItem.leftBarButtonItem = closeButton
    }
    
    override func setLayout() {
        [emailTextField, passwordTextField, nicknameTextField, signUpButton].forEach {
            view.addSubview($0)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    }
}
