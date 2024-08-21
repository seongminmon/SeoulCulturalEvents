//
//  SearchResultViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class SearchResultViewController: BaseViewController {
    
    private let viewModel: SearchResultViewModel
    
    init(viewModel: SearchResultViewModel) {
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
        let input = SearchResultViewModel.Input()
        let output = viewModel.transform(input: input)
    }
    
    override func setNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func setLayout() {
        
    }
}
