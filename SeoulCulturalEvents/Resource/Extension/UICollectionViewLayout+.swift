//
//  UICollectionViewLayout+.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit

extension UICollectionViewLayout {
    
    static func categoryLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let spacing: CGFloat = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        return layout
    }
    
//    static func createLayout() -> UICollectionViewLayout {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1),
//            heightDimension: .fractionalHeight(1)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .estimated(1),
//            heightDimension: .fractionalHeight(60)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 8
////        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
//        // 수평 스크롤
//        section.orthogonalScrollingBehavior = .continuous
//        
////        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
////        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
////            layoutSize: headerSize,
////            elementKind: UICollectionView.elementKindSectionHeader,
////            alignment: .top
////        )
////        section.boundarySupplementaryItems = [headerSupplementary]
//        
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }
    
}
