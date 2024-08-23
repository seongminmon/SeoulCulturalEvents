//
//  WriteViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/23/24.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa
import SnapKit
import Then

final class WriteViewController: BaseViewController {
    
    private let completeButton = UIBarButtonItem(title: "완료")
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = UITextField().then {
        $0.placeholder = "제목을 입력하세요"
        $0.font = .bold20
    }
    private let contentsTextView = UITextView().then {
        $0.font = .regular14
        $0.backgroundColor = .lightGray
        $0.isScrollEnabled = false
    }
    private let addImageButton = UIButton()
    
    private let viewModel = WriteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = WriteViewModel.Input(
            completeButtonTap: completeButton.rx.tap,
            titleText: titleTextField.rx.text.orEmpty,
            contentsText: contentsTextView.rx.text.orEmpty
        )
        let output = viewModel.transform(input: input)
        
        output.completeButtonEnabled
            .bind(to: completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // TODO: - contents입력시 키보드 위로 스크롤 올려주기
        
    }
    
    override func setNavigationBar() {
        navigationItem.title = "후기 작성하기"
        navigationItem.rightBarButtonItem = completeButton
    }
    
    override func setLayout() {
        [titleTextField, contentsTextView].forEach {
            contentView.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [scrollView, addImageButton].forEach {
            view.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        contentsTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension WriteViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        // 최대 5장까지 선택 가능
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        
//        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
//            if let image = object as? UIImage {
//                DispatchQueue.main.async {
//                    self?.profileImageView.image = image
//                    self?.profileImageData.onNext(image.pngData())
//                }
//            }
//        }
    }
}
