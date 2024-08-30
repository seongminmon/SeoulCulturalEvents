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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BaseViewController {
    
    // MARK: - Toast
    func showToast(_ message: String = "네트워크 통신에 실패하였습니다.") {
        view.makeToast(message, duration: 1, position: .center)
    }
    
    func showLoadingToast() {
        view.makeToastActivity(.center)
    }
    
    func hideLoadingToast() {
        view.hideToastActivity()
    }
    
    // MARK: - Alert
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
    
    func showFilterActionSheet(
        totalHandler: @escaping (UIAlertAction) -> Void,
        nowHandler: @escaping (UIAlertAction) -> Void
    ) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        let total = UIAlertAction(title: "모든 행사 보기", style: .default, handler: totalHandler)
        let now = UIAlertAction(title: "진행 중인 행사만 보기", style: .default, handler: nowHandler)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(total)
        alert.addAction(now)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func showEditActionSheet(
        editHandler: @escaping (UIAlertAction) -> Void,
        deleteHandler: @escaping (UIAlertAction) -> Void
    ) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        let edit = UIAlertAction(title: "수정", style: .default, handler: editHandler)
        let delete = UIAlertAction(title: "삭제", style: .destructive, handler: deleteHandler)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func showEditCommentAlert(
        comment: String,
        editHandler: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(title: "댓글 수정", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = comment
        }
        
        let save = UIAlertAction(title: "저장", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            editHandler(text)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(save)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
