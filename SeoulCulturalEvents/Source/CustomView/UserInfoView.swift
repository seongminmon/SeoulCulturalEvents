//
//  UserInfoView.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class UserInfoView: BaseView {
    
    private let profileImageView = ProfileImageView()
    private let nicknameLabel = UILabel().then {
        $0.font = .bold15
    }
    private let dateLabel = UILabel().then {
        $0.font = .regular14
        $0.textColor = .gray
    }
    
    override func setLayout() {
        [profileImageView, nicknameLabel, dateLabel].forEach {
            addSubview($0)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(40)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.height.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.height.equalTo(20)
        }
    }
    
    func configureUserInfo(_ data: UserModel) {
        let parameter = (data.profileImage ?? "").getKFParameter()
        profileImageView.kf.setImage(
            with: parameter.url,
            placeholder: UIImage.person,
            options: [.requestModifier(parameter.modifier)]
        )
        nicknameLabel.text = data.nick
    }
    
    func configureDate(_ createdAt: String) {
        if let date = createdAt.toISODate() {
            dateLabel.text = date.toString()
        }
    }
}
