//
//  ReservationViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/20/24.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class ReservationViewController: BaseViewController {
    
    private lazy var webView = WKWebView().then {
        $0.navigationDelegate = self
    }
    
    private let viewModel: ReservationViewModel
    
    init(viewModel: ReservationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func bind() {
        let input = ReservationViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.link
            .bind(with: self) { owner, url in
                guard let url else { return }
                let request = URLRequest(url: url)
                owner.webView.load(request)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "예매하기"
    }
    
    override func setLayout() {
        view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension ReservationViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        showLoadingToast()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingToast()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        hideLoadingToast()
        showToast(nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        showToast(nil)
    }
}
