//
//  SearchCollectionHeaderView.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit
import SnapKit
import Then

final class SettingCollectionHeaderView: UICollectionReusableView {
    
    private let separator = UIView().then {
        $0.backgroundColor = .systemGray6
    }
    private let titleLabel = UILabel().then {
        $0.font = .bold20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [separator, titleLabel].forEach {
            addSubview($0)
        }
        
        separator.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeader(_ text: String) {
        titleLabel.text = text
    }
}
