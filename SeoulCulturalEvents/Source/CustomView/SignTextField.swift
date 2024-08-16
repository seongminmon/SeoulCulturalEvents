//
//  SignTextField.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit

final class SignTextField: UITextField {
    
    init(placeholderText: String) {
        super.init(frame: .zero)
        textColor = .black
        placeholder = placeholderText
        textAlignment = .center
        autocapitalizationType = .none
        borderStyle = .none
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
