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
    
    // TODO: - UI 개선
    
    private let likeButton = UIBarButtonItem().then {
        $0.image = .emptyHeart
        $0.tintColor = .systemRed
    }
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let userInfoView = UserInfoView()
    private let userInfoButton = UIButton()
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
    private let commentButton = UIButton().then {
        $0.setTitle("댓글", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
    }
    
    init(viewModel: DetailPostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let viewModel: DetailPostViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = DetailPostViewModel.Input(
            viewDidLoad: Observable.just(()),
            likeButtonTap: likeButton.rx.tap,
            commentButtonTap: commentButton.rx.tap,
            userInfoButtonTap: userInfoButton.rx.tap
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
        
        output.post
            .map { "댓글 \($0.comments.count)" }
            .bind(to: commentButton.rx.title())
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
        
        output.commentButtonTap
            .bind(with: self) { owner, value in
                let vm = CommentViewModel(postID: value.0, commentList: value.1)
                let vc = CommentViewController(viewModel: vm)
                let nav = UINavigationController(rootViewController: vc)
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.userInfoButtonTap
            .bind(with: self) { owner, userID in
                if userID == UserDefaultsManager.userID {
                    let vc = MyProfileViewController()
                    owner.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vm = OthersProfileViewModel(userID: userID)
                    let vc = OthersProfileViewController(viewModel: vm)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.rightBarButtonItem = likeButton
    }
    
    override func setLayout() {
        [
            userInfoView,
            userInfoButton,
            titleLabel,
            collectionView,
            contentsLabel,
            commentButton
        ].forEach { contentView.addSubview($0) }
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        userInfoView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        userInfoButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(collectionView.snp.width).multipliedBy(0.8)
        }
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(contentsLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
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
