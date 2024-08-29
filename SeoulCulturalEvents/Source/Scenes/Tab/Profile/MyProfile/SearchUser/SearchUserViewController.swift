//
//  SearchUserViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/28/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class SearchUserViewController: BaseViewController {
    
    private let searchController = UISearchController().then {
        $0.searchBar.placeholder = "유저를 검색해보세요"
    }
    private let emptyView = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = .bold20
        $0.textAlignment = .center
    }
    private let tableView = UITableView().then {
        $0.register(
            SearchUserTableViewCell.self,
            forCellReuseIdentifier: SearchUserTableViewCell.identifier
        )
        $0.rowHeight = 80
        $0.keyboardDismissMode = .onDrag
        $0.isHidden = true
    }
    
    private let viewModel: SearchUserViewModel
    
    init(viewModel: SearchUserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
        let followButtonTap = PublishSubject<UserModel>()
        
        let input = SearchUserViewModel.Input(
        searchText: searchController.searchBar.rx.text.orEmpty,
        searchButtonTap: searchController.searchBar.rx.searchButtonClicked,
        followButtonTap: followButtonTap
        )
        let output = viewModel.transform(input: input)
        
        output.userList
            .bind(to: tableView.rx.items(
                cellIdentifier: SearchUserTableViewCell.identifier,
                cellType: SearchUserTableViewCell.self
            )) { [weak self] row, element, cell in
                guard let self else { return }
                cell.configureCell(element)
                cell.configureFollow(element.isFollow)
                cell.followButton.rx.tap
                    .bind(with: self) { owner, _ in
                        followButtonTap.onNext(element)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.userList
            .map { $0.isEmpty }
            .subscribe(with: self) { owner, isEmpty in
                owner.emptyView.isHidden = !isEmpty
                owner.tableView.isHidden = isEmpty
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserModel.self)
            .subscribe(with: self) { owner, user in
                let vm = OthersProfileViewModel(userID: user.id)
                let vc = OthersProfileViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "유저 검색"
        navigationItem.searchController = searchController
    }
    
    override func setLayout() {
        [emptyView, tableView].forEach {
            view.addSubview($0)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
