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

enum FilterOption {
    case total
    case now
}

final class SearchResultViewController: BaseViewController {
        
    private let filterButton = UIBarButtonItem().then {
        $0.image = .list
    }
    private let tableView = UITableView().then {
        $0.register(CulturalEventTableViewCell.self, forCellReuseIdentifier: CulturalEventTableViewCell.identifier)
        $0.separatorStyle = .none
        $0.rowHeight = 500
    }
    
    private let filterAction = PublishSubject<FilterOption>()
    private let viewModel: SearchResultViewModel
    
    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = SearchResultViewModel.Input(
            viewDidLoad: Observable.just(()),
            cellTap: tableView.rx.itemSelected,
            filterButtonTap: filterButton.rx.tap,
            filterAction: filterAction,
            prefetchRows: tableView.rx.prefetchRows
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
        
        output.scrollToTop
            .bind(with: self) { owner, _ in
                owner.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
        
        filterButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showFilterActionSheet { _ in
                    owner.filterAction.onNext(.total)
                } nowHandler: { _ in
                    owner.filterAction.onNext(.now)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.rightBarButtonItem = filterButton
    }
    
    override func setLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
