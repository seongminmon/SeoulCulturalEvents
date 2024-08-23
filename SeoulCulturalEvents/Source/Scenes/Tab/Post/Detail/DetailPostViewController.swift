//
//  DetailPostViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class DetailPostViewController: BaseViewController {
    
    // TODO: - 댓글 화면 만들기 + 댓글화면으로 이동
    
    private let likeButton = UIBarButtonItem().then {
        $0.image = .emptyHeart
        $0.tintColor = .systemRed
    }
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let userInfoView = UserInfoView()
    private let titleLabel = UILabel().then {
        $0.font = .bold20
        $0.numberOfLines = 0
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .imageLayout()
    ).then {
        $0.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.identifier
        )
        // MARK: - 이미지 긴 경우 세로스크롤이 되어서 막아둠
        $0.isScrollEnabled = false
    }
    private let contentsLabel = UILabel().then {
        $0.font = .regular15
        $0.numberOfLines = 0
    }
//    private let commentButton = UIButton()
    
    init(viewModel: DetailPostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: DetailPostViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = DetailPostViewModel.Input(
            viewDidLoad: Observable.just(()),
            likeButtonTap: likeButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.navigationTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.post
            .bind(with: self) { owner, data in
                owner.configureView(data)
            }
            .disposed(by: disposeBag)
        
        output.imageList
            .bind(to: collectionView.rx.items(
                cellIdentifier: ImageCollectionViewCell.identifier,
                cellType: ImageCollectionViewCell.self
            )) { row, element, cell in
                cell.configureCell(element)
            }
            .disposed(by: disposeBag)
        
        output.isLike
            .map { $0 ? UIImage.fillHeart : UIImage.emptyHeart }
            .bind(to: likeButton.rx.image)
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.rightBarButtonItem = likeButton
    }
    
    override func setLayout() {
        [
            userInfoView,
            titleLabel,
            collectionView,
            contentsLabel
        ].forEach { contentView.addSubview($0) }
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.width.verticalEdges.equalToSuperview()
        }
        userInfoView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(collectionView.snp.width).multipliedBy(0.8)
        }
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func configureView(_ data: PostModel) {
        userInfoView.configureUserInfo(data.creator)
        userInfoView.configureDate(data.createdAt)
        titleLabel.text = data.title
        contentsLabel.text = data.content
    }
}
