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
    
    // TODO: - 선택한 사진 삭제 기능
    
    private let completeButton = UIBarButtonItem(title: "완료")
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let addImageButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "0/5"
        config.image = .camera
        config.imagePlacement = .top
        config.imagePadding = 4
        
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .gray
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        $0.configuration = config
        
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .uploadImageLayout()
    ).then {
        $0.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.identifier
        )
        $0.showsHorizontalScrollIndicator = false
    }
    private let titleTextField = UITextField().then {
        $0.placeholder = "제목을 입력하세요"
        $0.font = .bold20
    }
    private let contentsTextView = UITextView().then {
        $0.font = .regular14
        $0.backgroundColor = .lightGray
        $0.isScrollEnabled = false
    }
    
    private let addImage = PublishSubject<Data?>()
    private let removeAllImage = PublishSubject<Void>()
    private let viewModel = WriteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = WriteViewModel.Input(
            completeButtonTap: completeButton.rx.tap,
            addImageButtonTap: addImageButton.rx.tap,
            titleText: titleTextField.rx.text.orEmpty,
            contentsText: contentsTextView.rx.text.orEmpty,
            addImage: addImage,
            removeAllImage: removeAllImage
        )
        let output = viewModel.transform(input: input)
        
        output.completeButtonEnabled
            .bind(to: completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.addImageButtonTap
            .bind(with: self) { owner, _ in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)
        
        output.imageList
            .map { "\($0.count)/5" }
            .bind(to: addImageButton.rx.title())
            .disposed(by: disposeBag)
        
        output.imageList
            .bind(to: collectionView.rx.items(
                cellIdentifier: ImageCollectionViewCell.identifier,
                cellType: ImageCollectionViewCell.self
            )) { row, element, cell in
                cell.imageView.image = UIImage(data: element ?? Data())
            }
            .disposed(by: disposeBag)
        
        output.uploadSuccess
            .bind(with: self) { owner, value in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.uploadFailure
            .bind(with: self) { owner, value in
                owner.makeNetworkFailureToast(value)
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "후기 작성하기"
        navigationItem.rightBarButtonItem = completeButton
    }
    
    override func setLayout() {
        [
            addImageButton,
            collectionView,
            titleTextField,
            contentsTextView
        ].forEach {
            contentView.addSubview($0)
        }
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        addImageButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(8)
            make.size.equalTo(60)
        }
        collectionView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(addImageButton.snp.trailing).offset(8)
            make.height.equalTo(60)
        }
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(addImageButton.snp.bottom).offset(8)
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
        configuration.selection = .ordered
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension WriteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        removeAllImage.onNext(())
        
        // TODO: - dispatchGroup
        
        for result in results {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    self?.addImage.onNext(image.jpegData(compressionQuality: 0.5))
                }
            }
        }
    }
}
