//
//  BaseView.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/22/24.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    func setLayout() {}
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
