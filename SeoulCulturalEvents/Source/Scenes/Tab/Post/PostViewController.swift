//
//  PostViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class PostViewController: BaseViewController {
    
    // MARK: - viewDidLoad에서 통신하는 대신 당겨서 새로고침으로 리로드하기
    // 항상 최신 데이터를 보장하는 것은 아님
    // ex) 디테일화면에서 댓글이나 좋아요를 하더라도 새로고침전엔 반영 X
    
    // TODO: - 당겨서 새로고침 기능 구현하기
    // TODO: - 페이지네이션
    // TODO: - 글쓰기 버튼 만들기
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .postLayout()
    ).then {
        $0.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
    }
    
    private let viewModel = PostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = PostViewModel.Input(
            viewDidLoad: Observable.just(()),
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
        navigationItem.title = "후기"
    }
    
    override func setLayout() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
