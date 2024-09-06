//
//  EditPostViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/30/24.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa
import SnapKit
import Then

final class EditPostViewController: BaseViewController {
    
    private let cancelButton = UIBarButtonItem(image: .xmark)
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
        $0.font = .regular15
        $0.textColor = .gray
        $0.text = "후기를 작성해보세요."
        $0.isScrollEnabled = false
    }
    
    var editHandler: (() -> Void)?
    private let imageList = BehaviorSubject<[Data?]>(value: [])
    private let viewModel: EditPostViewModel
    
    init(viewModel: EditPostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
        let deleteImage = PublishSubject<IndexPath>()
        
        let input = EditPostViewModel.Input(
            completeButtonTap: completeButton.rx.tap,
            addImageButtonTap: addImageButton.rx.tap,
            titleText: titleTextField.rx.text.orEmpty,
            contentsText: contentsTextView.rx.text.orEmpty,
            imageList: imageList,
            deleteImage: deleteImage
        )
        let output = viewModel.transform(input: input)
        
        cancelButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.completeButtonEnabled
            .bind(to: completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.savedPost
            .subscribe(with: self) { owner, post in
                owner.titleTextField.text = post.title
                owner.contentsTextView.text = post.content
                owner.contentsTextView.textColor = .black
            }
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
                cell.configureCell(element)
                cell.deleteButton.isHidden = false
                cell.deleteButton.rx.tap
                    .bind(with: self) { owner, _ in
                        if let indexPath = owner.collectionView.indexPath(for: cell) {
                            deleteImage.onNext(indexPath)
                        }
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.editSuccess
            .bind(with: self) { owner, value in
                owner.editHandler?()
                owner.dismiss(animated: true)
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.networkFailure
            .bind(with: self) { owner, value in
                owner.showToast(value)
            }
            .disposed(by: disposeBag)
        
        contentsTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                if owner.contentsTextView.textColor == .gray {
                    owner.contentsTextView.textColor = .black
                    owner.contentsTextView.text = nil
                }
            }
            .disposed(by: disposeBag)
        
        contentsTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if owner.contentsTextView.text == nil || owner.contentsTextView.text.isEmpty {
                    owner.contentsTextView.textColor = .gray
                    owner.contentsTextView.text = "후기를 작성해보세요."
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func setNavigationBar() {
        navigationItem.title = "수정하기"
        navigationItem.leftBarButtonItem = cancelButton
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
            make.top.equalTo(collectionView).inset(10)
            make.leading.equalToSuperview().inset(8)
            make.size.equalTo(80)
        }
        collectionView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(addImageButton.snp.trailing).offset(8)
            make.height.equalTo(100)
        }
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(addImageButton.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        contentsTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.lessThanOrEqualTo(200)
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

extension EditPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        showLoadingToast()
        
        let dispatchGroup = DispatchGroup()
        var tempList = [Data?]()
        
        for result in results {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    let data = image.jpegData(compressionQuality: 0.5)
                    tempList.append(data)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.imageList.onNext(tempList)
                self.hideLoadingToast()
            }
        }
    }
}
