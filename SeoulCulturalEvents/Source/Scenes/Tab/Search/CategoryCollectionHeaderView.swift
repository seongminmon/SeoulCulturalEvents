//
//  CategoryCollectionHeaderView.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit
import SnapKit
import Then

final class CategoryCollectionHeaderView: UICollectionReusableView {
    
    static let identifier = String(describing: CategoryCollectionHeaderView.self)
    
    private let titleLabel = UILabel().then {
        $0.font = .bold20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeader(_ text: String) {
        titleLabel.text = text
    }
}
