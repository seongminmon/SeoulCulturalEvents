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
    
    private let settingButton = UIBarButtonItem().then {
        $0.image = .ellipsis
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
    private let likeButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .emptyHeart
        config.imagePadding = 4
        $0.configuration = config
        $0.setTitle("좋아요", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.tintColor = .systemRed
    }
    private let commentButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .bubble
        config.imagePadding = 4
        $0.configuration = config
        $0.setTitle("댓글", for: .normal)
        $0.tintColor = .black
    }
    
    init(viewModel: DetailPostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let networkTrigger = PublishSubject<Void>()
    private let viewModel: DetailPostViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
        let editAction = PublishSubject<Void>()
        let deleteAction = PublishSubject<Void>()
        
        let input = DetailPostViewModel.Input(
            viewDidLoad: Observable.just(()),
            likeButtonTap: likeButton.rx.tap,
            commentButtonTap: commentButton.rx.tap,
            userInfoButtonTap: userInfoButton.rx.tap,
            settingButtonTap: settingButton.rx.tap,
            editAction: editAction,
            deleteAction: deleteAction,
            networkTrigger: networkTrigger
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
            .bind(to: likeButton.rx.image())
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
        
        output.settingButtonTap
            .subscribe(with: self) { owner, _ in
                owner.showEditActionSheet { _ in
                    editAction.onNext(())
                    
                } deleteHandler: { _ in
                    deleteAction.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        output.editPost
            .subscribe(with: self) { owner, post in
                let vm = EditPostViewModel(savedPost: post)
                let vc = EditPostViewController(viewModel: vm)
                vc.editHandler = { owner.networkTrigger.onNext(()) }
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.postDeleteSuccess
            .subscribe(with: self) { owner, _ in
                owner.showToast("삭제되었습니다.")
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.notMyPost
            .subscribe(with: self) { owner, _ in
                owner.showToast("다른 사람의 후기입니다!")
            }
            .disposed(by: disposeBag)
        
        output.networkFailure
            .subscribe(with: self) { owner, value in
                owner.showToast(value)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.rightBarButtonItem = settingButton
    }
    
    override func setLayout() {
        [
            userInfoView,
            userInfoButton,
            titleLabel,
            collectionView,
            contentsLabel,
            likeButton,
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
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(contentsLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(contentsLabel.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func configureView(_ data: PostModel) {
        userInfoView.configureUserInfo(data.creator)
        userInfoView.configureDate(data.createdAt)
        titleLabel.text = data.title
        contentsLabel.configureLineSpacing(data.content ?? "")
    }
}
