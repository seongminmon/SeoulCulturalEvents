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

final class SignInViewController: UIViewController {
    
    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let signInButton = PointButton(title: "로그인")
    let signUpButton = UIButton()
    
    let viewModel = SignInViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        configureLayout()
        configure()
        bind()
    }
    
    func bind() {
        let input = SignInViewModel.Input(
            signInTap: signInButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        // Driver >> drive
        // 스트림 공유(share 내장), 메인쓰레드 보장, 오류 허용 X
        
        // Observable<String>: next, complete, error 다 전달 가능 >> asDriver에서 매개변수로 에러가 들어왔을 때 처리 필요
        output.emailText
            .map { $0.joke }
            .drive(emailTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.emailText
            .map { "농담: \($0.id)" }
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        // (탭 같은 경우엔 에러가 안 들어와서 에러 처리를 위한 매개변수가 필요 없음)
//        let tap = signInButton.rx.tap
//            .asDriver()
    }
    
    func configure() {
        signUpButton.setTitle("회원이 아니십니까?", for: .normal)
        signUpButton.setTitleColor(Color.black, for: .normal)
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(signInButton.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
}
