//
//  UILabel+.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/29/24.
//

import UIKit

extension UILabel {
    func configureAttributedString(_ text: String, _ image: UIImage) {
        let attributedString = NSMutableAttributedString(string: "")
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image.withTintColor(.systemGray3)
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 18)
        
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: "  \(text)"))
        self.attributedText = attributedString
    }
}

