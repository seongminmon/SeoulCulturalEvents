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
        $0.numberOfLines = 2
    }
    private let dateLabel = UILabel().then {
        $0.font = .regular13
        $0.textColor = .gray
    }
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let likeCountLabel = UILabel().then {
        $0.text = "좋아요 0"
        $0.font = .regular14
        $0.textColor = .gray
    }
    private let commentCountLabel = UILabel().then {
        $0.text = "댓글 0"
        $0.font = .regular14
        $0.textColor = .gray
    }
    
    override func setLayout() {
        
        [
            titleLabel,
            contentsLabel,
            dateLabel,
            imageView,
            likeCountLabel,
            commentCountLabel
        ].forEach { contentView.addSubview($0) }
        
        imageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(80)
        }
        likeCountLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.trailing.equalTo(commentCountLabel.snp.leading).offset(-4)
            make.bottom.equalToSuperview()
        }
        commentCountLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(imageView.snp.leading).offset(-8)
        }
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(imageView.snp.leading).offset(-8)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentsLabel.snp.bottom).offset(4)
            make.leading.bottom.equalToSuperview()
            make.trailing.equalTo(likeCountLabel.snp.leading).offset(-8)
        }
    }
    
    func configureCell(_ data: PostModel) {
        titleLabel.text = data.title
        contentsLabel.text = data.content
        let parameter = (data.files.first ?? "").getKFParameter()
        imageView.kf.setImage(with: parameter.url, options: [.requestModifier(parameter.modifier)])
        dateLabel.text = data.createdAt.toISODate()?.toString()
        likeCountLabel.text = "좋아요 \(data.likes.count)"
        commentCountLabel.text = "댓글 \(data.comments.count)"
    }
}
