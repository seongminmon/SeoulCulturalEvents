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
    
    private let dateLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .gray
    }
    private let genreLabel = UILabel().then {
        $0.font = .bold14
    }
    private let shadowView = UIView().then {
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = .zero
        $0.layer.shadowRadius = 10
        $0.layer.shadowOpacity = 0.9
    }
    private let containerView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let mainImageView = UIImageView().then {
        $0.backgroundColor = .gray
        $0.contentMode = .scaleAspectFill
    }
    private let shareButton = UIButton().then {
        $0.setImage(.paperclip, for: .normal)
        $0.tintColor = .black
        $0.backgroundColor = .white
    }
    private let priceLabel = UILabel().then {
        $0.font = .bold14
        $0.textColor = .white
        $0.numberOfLines = 2
    }
    private let priceView = UIView().then {
        $0.backgroundColor = .systemIndigo
    }
    
    private let descriptionView = UIView().then {
        $0.backgroundColor = .white
    }
    private let titleLabel = UILabel().then {
        $0.font = .bold15
    }
    private let placeLabel = UILabel().then {
        $0.font = .bold14
        $0.numberOfLines = 2
    }
    private let separator = UIView().then {
        $0.backgroundColor = .black
    }
    private let detailLabel = UILabel().then {
        $0.text = "자세히 보기"
        $0.font = .regular14
    }
    private let detailButton = UIButton().then {
        $0.setImage(.chevron, for: .normal)
        $0.tintColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shareButton.clipsToBounds = true
        shareButton.layer.cornerRadius = shareButton.frame.width / 2
    }
    
    override func setLayout() {
        [dateLabel, genreLabel, shadowView].forEach {
            contentView.addSubview($0)
        }
        
        [
            titleLabel,
            placeLabel,
            separator,
            detailLabel,
            detailButton
        ].forEach {
            descriptionView.addSubview($0)
        }
        
        [
            mainImageView,
            shareButton,
            priceView,
            descriptionView
        ].forEach {
            containerView.addSubview($0)
        }
        
        priceView.addSubview(priceLabel)
        shadowView.addSubview(containerView)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(20)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(20)
        }
        
        shadowView.snp.makeConstraints { make in
            make.top.equalTo(genreLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(8)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(mainImageView.snp.width)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.size.equalTo(30)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(4)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        
        priceView.snp.makeConstraints { make in
            make.leading.bottom.equalTo(mainImageView).inset(16)
            make.trailing.lessThanOrEqualTo(mainImageView).inset(100)
        }
        
        descriptionView.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }
        
        placeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.bottom.equalTo(separator.snp.top).offset(-8)
        }
        
        separator.snp.makeConstraints { make in
            make.bottom.equalTo(detailButton.snp.top).offset(-4)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(1)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(detailButton)
            make.leading.bottom.equalToSuperview().inset(8)
            make.trailing.equalTo(detailButton.snp.leading).offset(-8)
        }
        
        detailButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(8)
            make.size.equalTo(25)
        }
    }
    
    func configureCell(data: CulturalEvent) {
        dateLabel.text = "\(data.startDateString) ~ \(data.endDateString)"
        genreLabel.text = "#\(data.codeName)"
        let imageURL = URL(string: data.mainImage)
        mainImageView.kf.setImage(with: imageURL)
        priceLabel.text = data.price.isEmpty ? data.isFree : data.price
        titleLabel.text = data.title
        placeLabel.text = "\(data.place) | \(data.guName)"
    }
}
