//
//  CulturalEventTableViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/18/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class CulturalEventTableViewCell: BaseTableViewCell {
    
    private let containerView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let mainImageView = UIImageView().then {
        $0.backgroundColor = .gray
        $0.contentMode = .scaleAspectFill
    }
    private let genreLabel = UILabel().then {
        $0.font = .bold14
    }
    private let priceLabel = UILabel().then {
        $0.font = .bold14
    }
    private let genreView = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0.8)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
    }
    private let priceView = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0.8)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
    }
    private let descriptionView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    private let titleLabel = UILabel().then {
        $0.font = .bold20
        $0.textColor = .white
        $0.numberOfLines = 2
    }
    private let placeLabel = UILabel().then {
        $0.font = .bold14
        $0.textColor = .white
        $0.numberOfLines = 2
    }
    private let dateLabel = UILabel().then {
        $0.font = .bold14
        $0.textColor = .white
    }
    
    override func setLayout() {
        genreView.addSubview(genreLabel)
        priceView.addSubview(priceLabel)
        [titleLabel, placeLabel, dateLabel].forEach {
            descriptionView.addSubview($0)
        }
        [mainImageView, genreView, priceView, descriptionView].forEach {
            containerView.addSubview($0)
        }
        contentView.addSubview(containerView)
        
        genreView.snp.makeConstraints { make in
            make.leading.top.equalTo(mainImageView).inset(16)
        }
        priceView.snp.makeConstraints { make in
            make.top.equalTo(mainImageView).inset(16)
            make.leading.equalTo(genreView.snp.trailing).offset(8)
        }
        genreLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
        priceLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        descriptionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(16)
        }
        
        placeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(placeLabel.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalToSuperview().inset(16)
            make.height.equalTo(20)
        }
    }
    
    func configureCell(data: CulturalEvent) {
        let imageURL = URL(string: data.mainImage)
        genreLabel.text = "#\(data.codeName)"
        dateLabel.text = "\(data.startDateString) ~ \(data.endDateString)"
        mainImageView.kf.setImage(with: imageURL)
        priceLabel.text = data.price.isEmpty ? "무료" : "유료"
        titleLabel.text = data.title
        placeLabel.text = "\(data.place) | \(data.guName)"
    }
}
