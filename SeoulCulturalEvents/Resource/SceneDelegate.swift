//
//  SceneDelegate.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let vc = SignInViewController()
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        
//        let tab = TabBarController()
//        window?.rootViewController = tab
        
//        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
    }
}
