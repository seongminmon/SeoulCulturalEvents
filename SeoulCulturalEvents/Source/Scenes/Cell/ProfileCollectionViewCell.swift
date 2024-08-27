//
//  ProfileCollectionViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import UIKit
import SnapKit
import Then

final class ProfileCollectionViewCell: BaseCollectionViewCell {
    
    private let imageBackgroundView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
    }
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .gray
    }
    private let label = UILabel().then {
        $0.font = .regular16
    }
    
    override func setLayout() {
        imageBackgroundView.addSubview(imageView)
        [imageBackgroundView, label].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        imageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(50)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    func configureCell(_ data: SettingItem) {
        imageView.image = data.image
        label.text = data.text
    }
}
