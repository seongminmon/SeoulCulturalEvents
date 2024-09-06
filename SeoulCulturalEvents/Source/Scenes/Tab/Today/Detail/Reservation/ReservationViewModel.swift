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
    
    struct Input {}
    
    struct Output {
        let link: Observable<URL?>
    }
    
    func transform(input: Input) -> Output {
        return Output(link: Observable.just(URL(string: link)))
    }
}
