//
//  CommentTableViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/25/24.
//

import UIKit
import SnapKit
import Then

final class CommentTableViewCell: BaseTableViewCell {
    
    private let userInfoView = UserInfoView()
    private let commentLabel = UILabel().then {
        $0.font = .regular14
        $0.numberOfLines = 0
    }
    
    override func setLayout() {
        [userInfoView, commentLabel].forEach {
            addSubview($0)
        }
        
        userInfoView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configureCell(_ data: CommentModel) {
        userInfoView.configureUserInfo(data.creator)
        userInfoView.configureDate(data.createdAt)
        commentLabel.text = data.content
    }
}
