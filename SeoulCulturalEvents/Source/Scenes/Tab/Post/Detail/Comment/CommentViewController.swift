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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
