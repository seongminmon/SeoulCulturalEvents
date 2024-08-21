//
//  CategoryCollectionViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class CategoryCollectionViewCell: BaseCollectionViewCell {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 14
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
    }
    private let categoryLabel = UILabel().then {
        $0.font = .bold15
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    override func setLayout() {
        containerView.addSubview(categoryLabel)
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.centerY.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    func configureCell(_ text: String) {
        categoryLabel.text = text
    }
    
    func toggleSelected(_ flag: Bool) {
        if flag {
            categoryLabel.textColor = .white
            containerView.backgroundColor = .systemPink
            containerView.layer.borderColor = UIColor.white.cgColor
        } else {
            categoryLabel.textColor = .black
            containerView.backgroundColor = .white
            containerView.layer.borderColor = UIColor.black.cgColor
        }
    }
}
