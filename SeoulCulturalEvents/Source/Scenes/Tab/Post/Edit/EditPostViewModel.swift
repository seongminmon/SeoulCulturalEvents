//
//  EditPostViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/30/24.
//

import Foundation
import Kingfisher
import RxSwift
import RxCocoa

final class EditPostViewModel: ViewModelType {
        
    private let savedPost: PostModel
    private let disposeBag = DisposeBag()
    
    init(savedPost: PostModel) {
        self.savedPost = savedPost
    }

    struct Input {
        let completeButtonTap: ControlEvent<Void>
        let addImageButtonTap: ControlEvent<Void>
        let titleText: ControlProperty<String>
        let contentsText: ControlProperty<String>
        let imageList: BehaviorSubject<[Data?]>
        let deleteImage: PublishSubject<IndexPath>
    }
    
    struct Output {
        let savedPost: BehaviorSubject<PostModel>
        let completeButtonEnabled: BehaviorSubject<Bool>
        let addImageButtonTap: ControlEvent<Void>
        let imageList: BehaviorSubject<[Data?]>
        let editSuccess: PublishSubject<Void>
        let networkFailure: PublishSubject<String?>
    }
    
    func transform(input: Input) -> Output {
        
        let savedPost = BehaviorSubject<PostModel>(value: savedPost)
        let completeButtonEnabled = BehaviorSubject<Bool>(value: false)
        let imageList = BehaviorSubject<[Data?]>(value: [])
        let editSuccess = PublishSubject<Void>()
        let networkFailure = PublishSubject<String?>()
        let imageUploadSuccess = PublishSubject<[String]>()
        
        let allContents = Observable.combineLatest(input.imageList, input.titleText, input.contentsText)
        
        savedPost
            .subscribe(with: self) { owner, post in
                
                let dispatchGroup = DispatchGroup()
                var dataList = [Data?]()
                
                for item in post.files {
                    dispatchGroup.enter()
                    let parameter = item.getKFParameter()
                    ImageDownloader.default.downloadImage(
                        with: parameter.url!,
                        options: [.requestModifier(parameter.modifier)]
                    ) { result in
                        switch result {
                        case .success(let value):
                            dataList.append(value.originalData)
                        case .failure(let error):
                            print("KF Error: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    DispatchQueue.main.async {
                        imageList.onNext(dataList)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // TODO: - 처음에 사진과 제목이 false가 되어 완료 버튼이 활성화되지 않는 문제
        // 이미지, 타이틀, 컨텐츠 모두 있을 때만 완료 버튼 활성화
        allContents
            .subscribe(with: self) { owner, value in
                print("완료버튼 유효성 검사")
                print("사진: \(!value.0.isEmpty)")
                print("제목: \(!value.1.isEmpty)")
                print("내용: \(!value.2.isEmpty)")
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
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 이미지 업로드 성공 시 포스트 수정
        Observable.combineLatest(imageUploadSuccess, allContents)
            .flatMap { files, value in
                let postID = self.savedPost.postID
                let query = PostQuery(title: value.1, productID: ProductID.post, content: value.2, files: files)
                return LSLPAPIManager.shared.callRequestWithRetry(
                    api: PostRouter.editPost(postID: postID, query: query),
                    model: PostModel.self
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 수정 성공")
                    editSuccess.onNext(())
                    
                case .failure(let error):
                    print("포스트 수정 실패")
                    networkFailure.onNext(error.errorDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.imageList
            .subscribe(with: self) { owner, value in
                imageList.onNext(value)
            }
            .disposed(by: disposeBag)
        
        input.deleteImage
            .withLatestFrom(imageList) { ($0, $1) }
            .subscribe(with: self) { owner, value in
                var list = value.1
                list.remove(at: value.0.item)
                imageList.onNext(list)
            }
            .disposed(by: disposeBag)
        
        return Output(
            savedPost: savedPost,
            completeButtonEnabled: completeButtonEnabled,
            addImageButtonTap: input.addImageButtonTap,
            imageList: imageList,
            editSuccess: editSuccess,
            networkFailure: networkFailure
        )
    }
}
