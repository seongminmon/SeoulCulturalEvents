//
//  TabBarController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tabBar.tintColor = .darkGray
        
        let today = UINavigationController(rootViewController: TodayViewController())
        today.tabBarItem = UITabBarItem(title: "투데이", image: nil, tag: 0)
        
        let search = UINavigationController(rootViewController: SearchViewController())
        search.tabBarItem = UITabBarItem(title: "검색", image: nil, tag: 1)
        
        let post = UINavigationController(rootViewController: PostViewController())
        post.tabBarItem = UITabBarItem(title: "후기", image: nil, tag: 2)
        
        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(title: "설정", image: nil, tag: 3)
 
        setViewControllers([today, search, post, profile], animated: true)
        
        tabBar.items?.forEach { $0.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0) }
    }
}
