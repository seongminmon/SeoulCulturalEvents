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
    
    let profileImageView = ProfileImageView()
    let nicknameLabel = UILabel().then {
        $0.font = .bold15
    }
    let dateLabel = UILabel().then {
        $0.font = .regular14
        $0.textColor = .gray
    }
    
    override func setLayout() {
        
    }
    
    func configureView(_ data: UserModel) {
        let parameter = (data.profileImage ?? "").getKFParameter()
//        profileImageView.kf.setImage(with: <#T##Source?#>)
    }
}
