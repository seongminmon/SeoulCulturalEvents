//
//  CommentViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/25/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class CommentViewController: BaseViewController {
    
    // TODO: - 내가 쓴 댓글 -> 수정, 삭제
    // TODO: - 키보드 활성화 시 댓글 올라가는 문제
    // TODO: - 댓글 작성 시 키보드 내리기 + 텍스트필드 비워주기
    
    private let tableView = UITableView().then {
        $0.register(
            CommentTableViewCell.self,
            forCellReuseIdentifier: CommentTableViewCell.identifier
        )
    }
    private let textField = UITextField().then {
        $0.placeholder = "댓글을 입력해주세요."
        $0.borderStyle = .roundedRect
    }
    private let confirmButton = UIButton().then {
        $0.setImage(.paperplane, for: .normal)
        $0.tintColor = .systemGreen
    }
    
    private let viewModel: CommentViewModel
    
    init(viewModel: CommentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = CommentViewModel.Input(
            comment: textField.rx.text.orEmpty,
            confirmButtonTap: confirmButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.commentList
            .bind(to: tableView.rx.items(
                cellIdentifier: CommentTableViewCell.identifier,
                cellType: CommentTableViewCell.self
            )) { row, element, cell in
                cell.configureCell(element)
            }
            .disposed(by: disposeBag)
        
    }
    
    override func setNavigationBar() {
        navigationItem.title = "댓글"
    }
    
    override func setLayout() {
        [tableView, textField, confirmButton].forEach {
            view.addSubview($0)
        }
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(textField.snp.top).offset(-8)
        }
        textField.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.trailing.equalTo(confirmButton.snp.leading).offset(-8)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(40)
        }
        confirmButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.size.equalTo(40)
        }
    }
}
