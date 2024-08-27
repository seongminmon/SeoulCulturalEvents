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
        $0.font = .bold20
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
        $0.setTitle("프로필 수정", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1
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
            make.top.leading.equalToSuperview().inset(16)
            make.size.equalTo(100)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.equalTo(profileImageView)
        }
        
        followerButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.leading.equalTo(profileImageView)
        }
        
        followingButton.snp.makeConstraints { make in
            make.top.equalTo(followerButton)
            make.leading.equalTo(followerButton.snp.trailing).offset(8)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(followerButton.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(40)
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
