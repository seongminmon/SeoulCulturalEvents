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
    
    private let profileView = ProfileView().then {
        $0.additionalButton.setTitle("팔로잉", for: .normal)
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
        let input = OthersProfileViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.profile
            .bind(with: self) { owner, profile in
                owner.navigationItem.title = profile.nick
                owner.profileView.configureView(profile)
            }
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
