//
//  SceneDelegate.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // TODO: - 결제 기능

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        LSLPAPIManager.shared.refresh { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                print("토큰 갱신 성공 (리프레시 토큰 유효)")
                let tab = TabBarController()
                window?.rootViewController = tab
                window?.makeKeyAndVisible()
                
            case .failure(_):
                print("토큰 갱신 실패 (리프레시 토큰 없음 or 만료)")
                let vc = SignInViewController()
                let nav = UINavigationController(rootViewController: vc)
                window?.rootViewController = nav
                window?.makeKeyAndVisible()
            }
        }
        
//        let vc = SignInViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        window?.rootViewController = nav
//        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    static func changeWindow(_ vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(
            with: window,
            duration: 0.2,
            options: [.transitionCrossDissolve],
            animations: nil,
            completion: nil
        )
    }
}
