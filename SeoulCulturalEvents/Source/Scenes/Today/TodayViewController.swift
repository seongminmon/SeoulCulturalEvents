//
//  TodayViewController.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import UIKit

final class TodayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cultureParameter = CultureParameter(startDate: 1, endDate: 10, codeName: .lecture, title: nil, date: nil)
        CultureAPIManager.shared.callRequest(cultureParameter)
    }
}
