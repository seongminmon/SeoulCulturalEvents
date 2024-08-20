//
//  ReserveViewController.swift
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

final class ReserveViewController: BaseViewController {
    
    private let webView = WKWebView()
    
    private let viewModel: ReserveViewModel
    
    init(viewModel: ReserveViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = ReserveViewModel.Input(
            viewDidLoad: Observable.just(())
        )
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
