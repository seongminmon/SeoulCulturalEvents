//
//  UICollectionViewLayout+.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit

extension UICollectionViewLayout {
    
    static func searchLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .estimated(30)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(30)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30))
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerSupplementary]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    static func imageLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .fractionalWidth(0.8)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    static func postLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        let spacing: CGFloat = 10
        let cellCount: CGFloat = 1
        
        let totalWidth = UIScreen.main.bounds.width - 2 * spacing - (cellCount-1) * spacing
        let width = totalWidth / cellCount
        let height: CGFloat = 100
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        return layout
    }
    
    static func uploadImageLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let width: CGFloat = 80
        let height: CGFloat = 80
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        return layout
    }
    
    static func settingLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .absolute(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30))
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerSupplementary]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
