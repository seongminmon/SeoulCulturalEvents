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
    
    // TODO: - 유저가 쓴 글 보여주기
    
    private let profileView = ProfileView()
    
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
            additionalButtonTap: profileView.additionalButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.profile
            .bind(with: self) { owner, profile in
                owner.navigationItem.title = profile.nick
                owner.profileView.configureView(profile)
            }
            .disposed(by: disposeBag)
        
        output.isFollow
            .map { $0 ? "팔로우 취소" : "팔로우" }
            .bind(to: profileView.additionalButton.rx.title())
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        
    }
    
    override func setLayout() {
        [profileView].forEach {
            view.addSubview($0)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(260)
        }
    }
}
