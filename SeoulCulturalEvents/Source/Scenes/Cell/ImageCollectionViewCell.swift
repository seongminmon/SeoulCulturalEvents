//
//  ImageCollectionViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class ImageCollectionViewCell: BaseCollectionViewCell {
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    override func setLayout() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureCell(_ file: String) {
        let parameter = file.getKFParameter()
        imageView.kf.setImage(with: parameter.url, options: [.requestModifier(parameter.modifier)])
    }
}
