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
    
    // MARK: - viewWillAppear 대신 당겨서 새로고침으로 리로드하도록 구현
    // >>> 항상 최신 데이터를 보장하는 것은 아님
    // ex) 디테일화면에서 댓글이나 좋아요를 하더라도 새로고침 전엔 반영 X
    
    private let refreshControl = UIRefreshControl()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .postLayout()
    ).then {
        $0.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
        $0.refreshControl = refreshControl
    }
    private let writeButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "글쓰기"
        config.image = .pencil
        config.imagePlacement = .leading
        config.imagePadding = 4
        config.buttonSize = .mini
        
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        $0.configuration = config
    }
    
    private let viewModel = PostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = PostViewModel.Input(
            viewDidLoad: Observable.just(()),
            cellTap: collectionView.rx.modelSelected(PostModel.self),
            refreshEvent: refreshControl.rx.controlEvent(.valueChanged),
            prefetchItems: collectionView.rx.prefetchItems
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
        
        output.postList
            .bind(with: self) { owner, _ in
                owner.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.cellTap
            .bind(with: self) { owner, value in
                let vm = DetailPostViewModel(postID: value.postID)
                let vc = DetailPostViewController(viewModel: vm)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.remainTime
            .bind(with: self) { owner, value in
                owner.view.makeToast("잠시 후 시도해주세요!", duration: 1, position: .center)
                owner.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        writeButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = WriteViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "후기 둘러보기"
    }
    
    override func setLayout() {
        [collectionView, writeButton].forEach {
            view.addSubview($0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        writeButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
