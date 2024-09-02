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
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let completeButtonTap: ControlEvent<Void>
        let addImageButtonTap: ControlEvent<Void>
        let titleText: ControlProperty<String>
        let contentsText: ControlProperty<String>
        let imageList: BehaviorSubject<[Data?]>
        let deleteTerms: PublishSubject<IndexPath>
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
        
        let allContents = Observable.combineLatest(input.imageList, input.titleText, input.contentsText)
        
        // 이미지, 타이틀, 컨텐츠 모두 있을 때만 완료 버튼 활성화
        allContents
            .subscribe(with: self) { owner, value in
                let flag = !value.0.isEmpty && !value.1.isEmpty && !value.2.isEmpty
                completeButtonEnabled.onNext(flag)
            }
            .disposed(by: disposeBag)
        
        // 포스트 이미지 업로드
        input.completeButtonTap
            .withLatestFrom(input.imageList)
            .map { value in
                value.compactMap { $0 }
            }
            .flatMap { files in
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: PostRouter.postImageFiles(files: files),
                    model: PostImageModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 이미지 업로드 성공")
                    imageUploadSuccess.onNext(data.files)
                    
                case .failure(let error):
                    print("포스트 이미지 업로드 실패")
                    print(error)
                    uploadFailure.onNext("이미지 업로드 실패")
                }
            }
            .disposed(by: disposeBag)
        
        // 이미지 업로드 성공 시 포스트 업로드
        Observable.combineLatest(imageUploadSuccess, allContents)
            .map { files, value in
                PostQuery(title: value.1, productID: ProductID.post, content: value.2, files: files)
            }
            .flatMap { query in
                LSLPAPIManager.shared.callRequestWithRetry(
                    api: PostRouter.createPost(query: query),
                    model: PostModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 업로드 성공")
                    uploadSuccess.onNext(())
                    
                case .failure(let error):
                    print("포스트 업로드 실패")
                    print(error)
                    uploadFailure.onNext("후기 업로드 실패")
                }
            }
            .disposed(by: disposeBag)
        
        input.imageList
            .subscribe(with: self) { owner, value in
                imageList.onNext(value)
            }
            .disposed(by: disposeBag)
        
        input.deleteTerms
            .withLatestFrom(imageList) { ($0, $1) }
            .subscribe(with: self) { owner, value in
                var list = value.1
                list.remove(at: value.0.item)
                imageList.onNext(list)
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
