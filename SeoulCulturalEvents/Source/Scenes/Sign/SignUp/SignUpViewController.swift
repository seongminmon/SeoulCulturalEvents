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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "회원가입"
        navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
