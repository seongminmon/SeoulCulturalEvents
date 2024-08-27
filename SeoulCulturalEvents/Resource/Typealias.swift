//
//  Typealias.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/23/24.
//

import UIKit
import RxDataSources

typealias SettingSection = AnimatableSectionModel<String, SettingItem>
typealias SearchSection = AnimatableSectionModel<String, String>

struct SettingItem: IdentifiableType, Equatable {
    let identity = UUID()
    let image: UIImage
    let text: String
}
