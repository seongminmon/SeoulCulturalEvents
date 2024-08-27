//
//  UserPostViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class UserPostViewController: BaseViewController {
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .postLayout()
    ).then {
        $0.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
    }
    
    private let viewModel: UserPostViewModel
    
    init(viewModel: UserPostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = UserPostViewModel.Input(
            cellTap: collectionView.rx.modelSelected(PostModel.self)
        )
        let output = viewModel.transform(input: input)
        
        output.postList
            .bind(to: collectionView.rx.items(
                cellIdentifier: PostCollectionViewCell.identifier,
                cellType: PostCollectionViewCell.self
            )) { row, element, cell in
                cell.configureCell(element)
            }
            .disposed(by: disposeBag)
        
        output.cellTap
            .bind(with: self) { owner, value in
                let vm = DetailPostViewModel(postID: value.postID)
                let vc = DetailPostViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "내 후기"
    }
    
    override func setLayout() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
