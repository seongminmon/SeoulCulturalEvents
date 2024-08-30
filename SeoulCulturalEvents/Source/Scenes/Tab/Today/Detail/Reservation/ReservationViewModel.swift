//
//  ReservationViewModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ReservationViewModel: ViewModelType {
    
    private let link: String
    private let disposeBag = DisposeBag()
    
    init(link: String) {
        self.link = link
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let link: Observable<URL?>
    }
    
    func transform(input: Input) -> Output {
        
        let link = BehaviorSubject<URL?>(value: nil)
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                link.onNext(URL(string: owner.link))
            }
            .disposed(by: disposeBag)
        
        return Output(link: link)
    }
}
