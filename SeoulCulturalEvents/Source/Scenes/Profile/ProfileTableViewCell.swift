//
//  ProfileTableViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import UIKit
import SnapKit
import Then

final class ProfileTableViewCell: BaseTableViewCell {
    
    private let mainLabel = UILabel().then {
        $0.font = .regular15
    }
    
    override func setLayout() {
        contentView.addSubview(mainLabel)
        
        mainLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    func configureCell(title: String) {
        mainLabel.text = title
    }
}
