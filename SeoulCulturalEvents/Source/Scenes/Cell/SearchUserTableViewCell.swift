//
//  SearchUserTableViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/28/24.
//

import UIKit
import RxSwift
import SnapKit
import Then

final class SearchUserTableViewCell: BaseTableViewCell {
    
    private let userInfoView = UserInfoView()
    let followButton = UIButton().then {
        $0.titleLabel?.font = .bold15
        $0.layer.cornerRadius = 10
    }
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setLayout() {
        [userInfoView, followButton].forEach {
            contentView.addSubview($0)
        }
        
        userInfoView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(followButton.snp.leading).offset(-8)
            make.height.equalTo(40)
        }
        
        followButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
    }
    
    func configureCell(_ data: UserModel) {
        userInfoView.configureUserInfo(data)
    }
    
    func configureFollow(_ isFollow: Bool) {
        if isFollow {
            followButton.setTitle("팔로잉", for: .normal)
            followButton.setTitleColor(.systemGray6, for: .normal)
            followButton.backgroundColor = .systemGray4
        } else {
            followButton.setTitle("팔로우", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = .systemGreen
        }
    }
}
