//
//  UserDefaultsManager.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    private enum Key: String {
        case access
        case refresh
        case userID
    }
    
    var accessToken: String {
        get { UserDefaults.standard.string(forKey: Key.access.rawValue) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Key.access.rawValue) }
    }
    
    var refreshToken: String {
        get { UserDefaults.standard.string(forKey: Key.refresh.rawValue) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Key.refresh.rawValue) }
    }
    
    var userID: String {
        get { UserDefaults.standard.string(forKey: Key.userID.rawValue) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Key.userID.rawValue) }
    }
    
    func refresh(_ access: String) {
        accessToken = access
    }
    
    func signIn(_ access: String, _ refresh: String, _ id: String) {
        accessToken = access
        refreshToken = refresh
        userID = id
    }
    
    func removeAll() {
        accessToken = ""
        refreshToken = ""
        userID = ""
    }
}
