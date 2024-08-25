//
//  ProfileView.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/24/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class ProfileView: BaseView {
    
    private let profileImageView = ProfileImageView()
    private let nicknameLabel = UILabel().then {
        $0.font = .bold16
    }
    let followerButton = UIButton().then {
        $0.titleLabel?.font = .regular14
        $0.setTitleColor(.black, for: .normal)
    }
    let followingButton = UIButton().then {
        $0.titleLabel?.font = .regular14
        $0.setTitleColor(.black, for: .normal)
    }
    let editButton = UIButton().then {
        $0.setImage(.chevron, for: .normal)
        $0.tintColor = .black
    }
    
    override func setLayout() {
        [
            profileImageView,
            nicknameLabel,
            followerButton,
            followingButton,
            editButton
        ].forEach {
            addSubview($0)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.size.equalTo(100)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView).offset(-16)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.equalTo(editButton.snp.leading)
        }
        
        followerButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nicknameLabel)
        }
        
        followingButton.snp.makeConstraints { make in
            make.top.equalTo(followerButton)
            make.leading.equalTo(followerButton.snp.trailing).offset(4)
        }
        
        editButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(40)
        }
    }
    
    func configureView(_ profile: ProfileModel) {
        let parameter = (profile.profileImage ?? "").getKFParameter()
        profileImageView.kf.setImage(
            with: parameter.url,
            placeholder: UIImage.person,
            options: [.requestModifier(parameter.modifier)]
        )
        nicknameLabel.text = profile.nick
        followerButton.setTitle("팔로워 \(profile.followers.count)", for: .normal)
        followingButton.setTitle("팔로잉 \(profile.following.count)", for: .normal)
    }
}
