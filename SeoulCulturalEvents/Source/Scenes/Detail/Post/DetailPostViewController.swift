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
    private let contentsLabel = UILabel().then {
        $0.font = .regular15
        $0.numberOfLines = 0
    }
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .imageLayout()
    ).then {
        $0.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        $0.isScrollEnabled = false
    }
    
    private let viewModel = DetailPostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = DetailPostViewModel.Input()
        let output = viewModel.transform(input: input)
        
    }
    
    override func setNavigationBar() {
        navigationItem.rightBarButtonItem = likeButton
    }
    
    override func setLayout() {
        [
            userInfoView,
            titleLabel,
            contentsLabel,
            collectionView
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
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentsLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
