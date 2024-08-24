//
//  EditProfileViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import UIKit
import PhotosUI
import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import Then

final class EditProfileViewController: BaseViewController {
    
    private let saveButton = UIBarButtonItem(title: "저장")
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
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
    
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: EditProfileViewModel
    private let profileImageData = BehaviorSubject<Data?>(value: nil)
    
    // 역값 전달
    var sendData: ((ProfileModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = EditProfileViewModel.Input(
            nickname: nicknameTextField.rx.text.orEmpty,
            profileImageData: profileImageData,
            profileSelectButtonTap: profileSelectButton.rx.tap,
            saveButtonTap: saveButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.profile
            .subscribe(with: self) { owner, value in
                let parameter = (value.profileImage ?? "").getKFParameter()
                owner.profileImageView.kf.setImage(
                    with: parameter.url,
                    options: [.requestModifier(parameter.modifier)]
                )
                owner.nicknameTextField.text = value.nick
                owner.nicknameTextField.sendActions(for: .editingChanged)
            }
            .disposed(by: disposeBag)
        
        output.profileSelectButtonTap
            .bind(with: self) { owner, _ in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)
        
        output.editProfileSuccess
            .bind(with: self) { owner, value in
                owner.sendData?(value)
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.editProfileFailure
            .bind(with: self) { owner, _ in
                print("로그인 뷰로 이동")
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "프로필 수정"
        navigationItem.rightBarButtonItem = saveButton
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
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                    self?.profileImageData.onNext(image.jpegData(compressionQuality: 0.5))
                }
            }
        }
    }
}
