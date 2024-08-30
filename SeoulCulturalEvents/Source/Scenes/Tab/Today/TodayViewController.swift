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
        $0.register(
            CulturalEventTableViewCell.self,
            forCellReuseIdentifier: CulturalEventTableViewCell.identifier
        )
        $0.separatorStyle = .none
        $0.rowHeight = 500
    }
    
    private let viewModel = TodayViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = TodayViewModel.Input(
            viewDidLoad: Observable.just(()),
            cellTap: tableView.rx.itemSelected,
            prefetchRows: tableView.rx.prefetchRows
        )
        let output = viewModel.transform(input: input)
        
        output.cultureList
            .bind(to: tableView.rx.items(
                    cellIdentifier: CulturalEventTableViewCell.identifier,
                    cellType: CulturalEventTableViewCell.self
            )) { row, element, cell in
                cell.configureCell(data: element)
            }
            .disposed(by: disposeBag)
        
        output.networkFailure
            .bind(with: self) { owner, value in
                owner.showToast(value)
            }
            .disposed(by: disposeBag)
        
        output.cellTap
            .bind(with: self) { owner, value in
                let vm = CulturalEventViewModel(culturalEvent: value)
                let vc = CulturalEventViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "오늘의 문화 행사"
    }
    
    override func setLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
