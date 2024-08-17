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
    
    private let confirmButton = UIBarButtonItem(title: "저장")
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .lightGray
    }
    private let profileSelectButton = UIButton().then {
        $0.setTitle("갤러리에서 선택", for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
    }
    private let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    
    // MARK: - 선택 사항
//    private let phoneNumberTextField = SignTextField(placeholderText: "전화번호를 입력해주세요")
//    private let birthDayTextField = SignTextField(placeholderText: "생일을 입력해주세요")
    
    private let viewModel = EditProfileViewModel()
    private var itemProviders: [NSItemProvider] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
//        closeButton.rx.tap
//        confirmButton.rx.tap
        profileSelectButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "프로필 수정"
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    override func setLayout() {
        [profileImageView, profileSelectButton, nicknameTextField].forEach {
            view.addSubview($0)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
        
        profileSelectButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalTo(profileImageView)
            make.height.equalTo(40)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(profileSelectButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension EditProfileViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        itemProviders = results.map(\.itemProvider)
        
        if let result = results.first {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }
        }
    }
}
