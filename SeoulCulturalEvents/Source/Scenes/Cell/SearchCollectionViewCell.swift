//
//  SearchCollectionViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import UIKit
import Kingfisher
import RxSwift
import SnapKit
import Then

final class SearchCollectionViewCell: BaseCollectionViewCell {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
    }
    private let categoryLabel = UILabel().then {
        $0.font = .bold15
        $0.textColor = .black
        $0.textAlignment = .center
    }
    let deleteButton = UIButton().then {
        $0.setImage(.xmark, for: .normal)
        $0.tintColor = .black
    }
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setLayout() {
        [categoryLabel, deleteButton].forEach {
            containerView.addSubview($0)
        }
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.centerY.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(10)
        }
    }
    
    func configureCell(_ text: String) {
        categoryLabel.text = text
    }
}
