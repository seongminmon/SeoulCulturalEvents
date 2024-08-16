//
//  EditProfileViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa
import SnapKit
import Then

final class EditProfileViewController: BaseViewController {
    
    private let viewModel = EditProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
    }
    
    override func setNavigationBar() {
        navigationItem.title = "프로필 수정"
    }
    
    override func setLayout() {
        
    }
}
