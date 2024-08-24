//
//  WriteViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class WriteViewModel: ViewModelType {
    
    private var imageList = [Data?]()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let completeButtonTap: ControlEvent<Void>
        let addImageButtonTap: ControlEvent<Void>
        let titleText: ControlProperty<String>
        let contentsText: ControlProperty<String>
        let addImage: PublishSubject<Data?>
        let removeAllImage: PublishSubject<Void>
    }
    
    struct Output {
        let completeButtonEnabled: BehaviorSubject<Bool>
        let addImageButtonTap: ControlEvent<Void>
        let imageList: BehaviorSubject<[Data?]>
        let uploadSuccess: PublishSubject<Void>
        let uploadFailure: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        
        let completeButtonEnabled = BehaviorSubject<Bool>(value: false)
        let imageList = BehaviorSubject<[Data?]>(value: [])
        let uploadSuccess = PublishSubject<Void>()
        let uploadFailure = PublishSubject<String>()
        
        let imageUploadSuccess = PublishSubject<[String]>()
        let titleAndContents = Observable.combineLatest(input.titleText, input.contentsText)
        
        // 이미지, 타이틀, 컨텐츠 모두 있을 때만 완료 버튼 활성화
        titleAndContents
            .subscribe(with: self) { owner, value in
                let flag = !value.0.isEmpty && !value.1.isEmpty && !owner.imageList.isEmpty
                completeButtonEnabled.onNext(flag)
            }
            .disposed(by: disposeBag)
        
        // 포스트 이미지 업로드
        input.completeButtonTap
            .withUnretained(self)
            .map { _ in
                self.imageList.compactMap { $0 }
            }
            .flatMap { files in
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: .postImageFiles(files: files),
                    model: PostImageModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 이미지 업로드 성공")
                    imageUploadSuccess.onNext(data.files)
                    
                case .failure(let error):
                    // 400번으로 실패
                    print("포스트 이미지 업로드 실패")
                    print(error)
                    uploadFailure.onNext("이미지 업로드 실패")
                }
            }
            .disposed(by: disposeBag)
        
        // 이미지 업로드 성공 시 포스트 업로드
        Observable.combineLatest(imageUploadSuccess, titleAndContents)
            .map { PostQuery(title: $0.1.0, productID: ProductID.post, content: $0.1.1, files: $0.0) }
            .flatMap { query in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: .createPost(query: query),
                    model: PostModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 업로드 성공")
                    dump(data)
                    uploadSuccess.onNext(())
                    
                case .failure(let error):
                    print("포스트 업로드 실패")
                    print(error)
                    uploadFailure.onNext("후기 업로드 실패")
                }
            }
            .disposed(by: disposeBag)
        
        input.removeAllImage
            .subscribe(with: self) { owner, _ in
                owner.imageList.removeAll()
            }
            .disposed(by: disposeBag)
        
        input.addImage
            .subscribe(with: self) { owner, data in
                owner.imageList.append(data)
                imageList.onNext(owner.imageList)
            }
            .disposed(by: disposeBag)
        
        return Output(
            completeButtonEnabled: completeButtonEnabled,
            addImageButtonTap: input.addImageButtonTap,
            imageList: imageList,
            uploadSuccess: uploadSuccess,
            uploadFailure: uploadFailure
        )
    }
}
