//
//  SignInViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class SignInViewController: BaseViewController {
    
    private let mainLabel = UILabel().then {
        $0.text = "서울시 문화 행사"
        $0.font = .bold36
        $0.textColor = .systemGreen
        $0.textAlignment = .center
    }
    private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요").then {
        $0.isSecureTextEntry = true
    }
    private let signInButton = PointButton(title: "로그인")
    private let signUpButton = UIButton().then {
        $0.setTitle("이메일로 회원가입", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    private let viewModel = SignInViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = SignInViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty,
            passwordText: passwordTextField.rx.text.orEmpty,
            signInTap: signInButton.rx.tap,
            signUpTap: signUpButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.signInSuccess
            .bind(with: self) { owner, _ in
                SceneDelegate.changeWindow(TabBarController())
            }
            .disposed(by: disposeBag)
        
        output.signInFailure
            .bind(with: self) { owner, value in
                owner.showToast(value)
            }
            .disposed(by: disposeBag)
        
        output.signUpTap
            .bind(with: self) { owner, _ in
                let vc = SignUpViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.navigationBar.tintColor = .black
                nav.modalPresentationStyle = .fullScreen
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setLayout() {
        [
            mainLabel,
            emailTextField,
            passwordTextField,
            signInButton,
            signUpButton
        ].forEach { view.addSubview($0) }
        
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(200)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    }
}
