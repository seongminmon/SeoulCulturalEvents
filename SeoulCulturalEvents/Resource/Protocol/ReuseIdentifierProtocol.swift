//
//  ReuseIdentifierProtocol.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import UIKit

protocol ReuseIdentifierProtocol: AnyObject {
    static var identifier: String { get }
}

extension UICollectionReusableView: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}


