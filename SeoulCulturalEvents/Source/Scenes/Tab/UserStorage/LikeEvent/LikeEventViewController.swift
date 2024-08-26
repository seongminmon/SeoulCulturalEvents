//
//  LikeEventViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class LikeEventViewController: BaseViewController {
    
    private let tableView = UITableView().then {
        $0.register(CulturalEventTableViewCell.self, forCellReuseIdentifier: CulturalEventTableViewCell.identifier)
        $0.separatorStyle = .none
    }
    private let viewModel: LikeEventViewModel
    
    init(viewModel: LikeEventViewModel) {
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
        let input = LikeEventViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.eventList
            .bind(to: tableView.rx.items(
                    cellIdentifier: CulturalEventTableViewCell.identifier,
                    cellType: CulturalEventTableViewCell.self
            )) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "관심 행사"
    }
    
    override func setLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
