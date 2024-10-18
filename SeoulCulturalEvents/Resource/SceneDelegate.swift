//
//  SceneDelegate.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var errorWindow: UIWindow?
    let networkMonitor = NetworkMonitor()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // 로그인 여부 분기 처리
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
        
        // 네트워크 감지
        networkMonitor.startMonitoring { [weak self] isConnected in
            guard let self else { return }
            if isConnected {
                print("네트워크 연결됨")
                removeNetworkErrorWindow()
            } else {
                print("네트워크 연결 오류")
                loadNetworkErrorWindow(on: scene)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        networkMonitor.stopMonitoring()
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

// MARK: - 네트워크 감지
extension SceneDelegate {
    private func loadNetworkErrorWindow(on scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = .statusBar
        window.makeKeyAndVisible()
        
        let noNetworkView = NoNetworkView(frame: window.bounds)
        window.addSubview(noNetworkView)
        self.errorWindow = window
    }
    
    private func removeNetworkErrorWindow() {
        errorWindow?.resignKey()
        errorWindow?.isHidden = true
        errorWindow = nil
    }
}
