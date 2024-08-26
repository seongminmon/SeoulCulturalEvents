//
//  UserDefaultsManager.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

enum UserDefaultsManager {
    
    private enum Key: String {
        case access
        case refresh
        case userID
        case recentSearchTerms
    }
    
    @UserDefault(key: Key.access.rawValue, defaultValue: "")
    static var accessToken
    
    @UserDefault(key: Key.refresh.rawValue, defaultValue: "")
    static var refreshToken
    
    @UserDefault(key: Key.userID.rawValue, defaultValue: "")
    static var userID
    
    @UserDefault<[String]>(key: Key.recentSearchTerms.rawValue, defaultValue: [])
    static var recentSearchTerms
    
    static func refresh(_ access: String) {
        UserDefaultsManager.accessToken = access
    }
    
    static func signIn(_ access: String, _ refresh: String, _ id: String) {
        UserDefaultsManager.accessToken = access
        UserDefaultsManager.refreshToken = refresh
        UserDefaultsManager.userID = id
    }
    
    static func removeAll() {
        UserDefaultsManager.accessToken = ""
        UserDefaultsManager.refreshToken = ""
        UserDefaultsManager.userID = ""
    }
}
