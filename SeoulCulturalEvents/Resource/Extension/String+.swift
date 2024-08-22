//
//  String+.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Kingfisher

extension String {
    
    func toDate(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss.S") -> Date? {
        Formatter.dateFormatter.dateFormat = dateFormat
        return Formatter.dateFormatter.date(from: self)
    }
    
    func toISODate() -> Date? {
        return Formatter.isoDateFormatter.date(from: self)
    }
    
    func getKFParameter() -> KFParameter {
        let url = URL(string: APIURL.lslpURL + "v1/" + self)
        let modifier = AnyModifier { request in
            var requestBody = request
            requestBody.setValue(APIKey.lslpKey, forHTTPHeaderField: LSLPHeader.sesacKey.rawValue)
            requestBody.setValue(UserDefaultsManager.shared.accessToken, forHTTPHeaderField: LSLPHeader.authorization.rawValue)
            return requestBody
        }
        return KFParameter(url: url, modifier: modifier)
    }
    
    func toCulturalEvent() -> CulturalEvent {
        let arr = self.components(separatedBy: "$$$")
        return CulturalEvent(
            mainImage: arr[0],
            title: arr[1],
            codeName: arr[2],
            startDate: arr[3],
            endDate: arr[4],
            place: arr[5],
            organizationName: arr[6],
            guName: arr[7],
            longitude: arr[8],
            latitude: arr[9],
            price: arr[10],
            isFree: arr[11],
            useTarget: arr[12],
            link: arr[13]
        )
    }
}
