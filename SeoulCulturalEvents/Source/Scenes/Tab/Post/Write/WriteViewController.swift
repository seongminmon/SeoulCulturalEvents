//
//  WriteViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class WriteViewController: BaseViewController {
    
    private let viewModel = WriteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = WriteViewModel.Input()
        let output = viewModel.transform(input: input)
        
    }
    
    override func setNavigationBar() {
        navigationItem.title = "후기 작성하기"
    }
    
    override func setLayout() {
        
    }
}
