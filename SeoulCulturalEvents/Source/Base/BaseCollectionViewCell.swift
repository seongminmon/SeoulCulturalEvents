//
//  BaseCollectionViewCell.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setLayout()
    }
    
    func setLayout() {}
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
