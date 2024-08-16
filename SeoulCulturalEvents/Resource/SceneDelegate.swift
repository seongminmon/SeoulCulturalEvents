//
//  SceneDelegate.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let disposeBag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        LSLPAPIManager.shared.callRequest(api: .refresh, model: RefreshModel.self)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("토큰 갱신 성공 (리프레시 토큰 유효)")
                    let tab = TabBarController()
                    owner.window?.rootViewController = tab
                    owner.window?.makeKeyAndVisible()
                    
                case .failure(let error):
                    print("토큰 갱신 실패 (리프레시 토큰 없음 or 만료")
                    let vc = SignInViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    owner.window?.rootViewController = nav
                    owner.window?.makeKeyAndVisible()
                }
            }
            .disposed(by: disposeBag)
    }
}
