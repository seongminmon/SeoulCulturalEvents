//
//  OthersProfileViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/27/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class OthersProfileViewController: BaseViewController {
    
    private let profileView = ProfileView()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .postLayout()
    ).then {
        $0.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )
    }
    
    private let viewModel: OthersProfileViewModel
    
    init(viewModel: OthersProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = OthersProfileViewModel.Input(
            additionalButtonTap: profileView.additionalButton.rx.tap,
            cellTap: collectionView.rx.modelSelected(PostModel.self)
        )
        let output = viewModel.transform(input: input)
        
        output.profile
            .bind(with: self) { owner, profile in
                owner.navigationItem.title = profile.nick
                owner.profileView.configureView(profile)
            }
            .disposed(by: disposeBag)
        
        output.isFollow
            .subscribe(with: self) { owner, value in
                owner.profileView.configureAdditionalButton(value)
            }
            .disposed(by: disposeBag)
        
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
        
        output.networkFailure
            .subscribe(with: self) { owner, value in
                owner.showToast(value)
            }
            .disposed(by: disposeBag)
    }
    
    override func setLayout() {
        [profileView, collectionView].forEach {
            view.addSubview($0)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(260)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
