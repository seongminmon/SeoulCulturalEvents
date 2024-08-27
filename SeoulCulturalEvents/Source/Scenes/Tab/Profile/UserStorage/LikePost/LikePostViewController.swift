//
//  LikePostViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class LikePostViewController: BaseViewController {
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .postLayout()
    ).then {
        $0.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
    }
    
    private let viewModel: LikePostViewModel
    
    init(viewModel: LikePostViewModel) {
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
        let input = LikePostViewModel.Input(
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
        navigationItem.title = "관심 후기"
    }
    
    override func setLayout() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
