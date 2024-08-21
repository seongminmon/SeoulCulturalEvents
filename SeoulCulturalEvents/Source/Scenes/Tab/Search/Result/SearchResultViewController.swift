//
//  SearchResultViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class SearchResultViewController: BaseViewController {
    
    private let tableView = UITableView().then {
        $0.register(CulturalEventTableViewCell.self, forCellReuseIdentifier: CulturalEventTableViewCell.identifier)
        $0.separatorStyle = .none
    }
    
    private let viewModel: SearchResultViewModel
    
    init(viewModel: SearchResultViewModel) {
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
        let input = SearchResultViewModel.Input(
            viewDidLoad: Observable.just(()),
            cellTap: tableView.rx.itemSelected
        )
        let output = viewModel.transform(input: input)
        
        output.navigationTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
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
                owner.makeNetworkFailureToast(value)
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
        
    }
    
    override func setLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
