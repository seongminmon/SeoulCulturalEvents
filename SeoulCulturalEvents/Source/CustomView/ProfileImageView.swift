//
//  ProfileImageView.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import UIKit

final class ProfileImageView: UIImageView {
    
    init() {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        tintColor = .systemGray4
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray6.cgColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        layer.cornerRadius = frame.width / 2
    }
}
