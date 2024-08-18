//
//  TodayViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class TodayViewController: BaseViewController {
    
    private let tableView = UITableView().then {
        $0.register(TodayTableViewCell.self, forCellReuseIdentifier: TodayTableViewCell.identifier)
    }
    
    private let viewModel = TodayViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = TodayViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        let output = viewModel.transform(input: input)
        
        output.cultureList
            .bind(to: tableView.rx.items(
                    cellIdentifier: TodayTableViewCell.identifier,
                    cellType: TodayTableViewCell.self
            )) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
        
    }
    
    override func setNavigationBar() {
        navigationItem.title = "오늘의 행사"
    }
    
    override func setLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
