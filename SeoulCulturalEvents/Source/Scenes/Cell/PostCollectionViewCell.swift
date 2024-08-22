//
//  PostCollectionViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import UIKit
import SnapKit
import Then

final class PostCollectionViewCell: BaseCollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.font = .bold15
        $0.numberOfLines = 2
    }
    private let contentsLabel = UILabel().then {
        $0.font = .regular14
        $0.textColor = .gray
    }
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let likeCountLabel = UILabel().then {
        $0.font = .regular14
        $0.textColor = .gray
    }
    private let commentCountLabel = UILabel().then {
        $0.font = .regular14
        $0.textColor = .gray
    }
    
    override func setLayout() {
        [
            titleLabel,
            contentsLabel,
            imageView,
            likeCountLabel,
            commentCountLabel
        ].forEach { contentView.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(imageView.snp.leading).offset(-8)
        }
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(titleLabel)
        }
        imageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.bottom.equalTo(likeCountLabel.snp.top).offset(4)
            make.width.equalTo(imageView.snp.height)
        }
        likeCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(commentCountLabel.snp.leading).offset(-4)
            make.bottom.equalToSuperview()
        }
        commentCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(imageView)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureCell(_ data: PostModel) {
        titleLabel.text = data.title
        contentsLabel.text = data.content
        let parameter = (data.files.first ?? "").getKFParameter()
        imageView.kf.setImage(with: parameter.url, options: [.requestModifier(parameter.modifier)])
        likeCountLabel.text = "좋아요 \(data.likes.count)"
        commentCountLabel.text = "좋아요 \(data.comments.count)"
    }
}
