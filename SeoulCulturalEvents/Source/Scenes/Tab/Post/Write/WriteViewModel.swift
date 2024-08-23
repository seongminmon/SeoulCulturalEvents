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
        let titleText: ControlProperty<String>
        let contentsText: ControlProperty<String>
    }
    
    struct Output {
        let completeButtonEnabled: BehaviorSubject<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let completeButtonEnabled = BehaviorSubject<Bool>(value: false)
        
        let titleAndContents = Observable.combineLatest(input.titleText, input.contentsText)
        
        titleAndContents
            .subscribe(with: self) { owner, value in
                let flag = !value.0.isEmpty && !value.1.isEmpty
                completeButtonEnabled.onNext(flag)
            }
            .disposed(by: disposeBag)
        
        input.completeButtonTap
            .withLatestFrom(titleAndContents)
            .subscribe(with: self) { owner, value in
                print("완료 버튼 탭: \(value)")
            }
            .disposed(by: disposeBag)
        
        return Output(
            completeButtonEnabled: completeButtonEnabled
        )
    }
}
