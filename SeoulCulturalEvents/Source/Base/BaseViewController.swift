//
//  BaseViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift
import Toast

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = .white
        
        setNavigationBar()
        setLayout()
        bind()
    }
    
    func setNavigationBar() {}
    func setLayout() {}
    func bind() {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension BaseViewController {
    
    func makeNetworkFailureToast(_ message: String = "네트워크 통신에 실패하였습니다.") {
        view.makeToast(message, duration: 1, position: .center)
    }
    
    func showLoadingToast() {
        view.makeToastActivity(.center)
    }
    
    func hideLoadingToast() {
        view.hideToastActivity()
    }
    
    func showWithdrawAlert(
        title: String,
        message: String,
        actionTitle: String,
        completionHandler: @escaping (UIAlertAction) -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "탈퇴하기", style: .destructive, handler: completionHandler)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
