//
//  ImageCollectionViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import UIKit
import Kingfisher
import RxSwift
import SnapKit
import Then

final class ImageCollectionViewCell: BaseCollectionViewCell {
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .gray
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    let deleteButton = UIButton().then {
        $0.setImage(.xmark, for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 10
        $0.isHidden = true
    }
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setLayout() {
        [imageView, deleteButton].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView.snp.top)
            make.centerX.equalTo(imageView.snp.trailing)
            make.size.equalTo(20)
        }
    }
    
    func configureCell(_ file: String) {
        let parameter = file.getKFParameter()
        imageView.kf.setImage(with: parameter.url, options: [.requestModifier(parameter.modifier)])
    }
    
    func configureCell(_ data: Data?) {
        imageView.image = UIImage(data: data ?? Data())
    }
}
