//
//  NoNetworkView.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/6/24.
//

import UIKit
import SnapKit
import Then

final class NoNetworkView: BaseView {
    
    private let noNetworkImage = UIImageView().then {
        $0.image = .noNetwork
        $0.tintColor = .systemPink
    }
    private let label = UILabel().then {
        $0.text = "인터넷 연결이 원활하지 않습니다."
        $0.font = .bold20
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    override func setLayout() {
        backgroundColor = .white
        [noNetworkImage, label].forEach {
            addSubview($0)
        }
        noNetworkImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(noNetworkImage.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
