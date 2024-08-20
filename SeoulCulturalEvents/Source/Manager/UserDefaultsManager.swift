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
        case likeTitles
        case likeIDs
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
    
    var likeTitles: [String] {
        get { UserDefaults.standard.object(forKey: Key.likeTitles.rawValue) as? [String] ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: Key.likeTitles.rawValue) }
    }
    
    var likeIDs: [String] {
        get { UserDefaults.standard.object(forKey: Key.likeIDs.rawValue) as? [String] ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: Key.likeIDs.rawValue) }
    }
    
    func refresh(_ access: String) {
        accessToken = access
    }
    
    // TODO: - 새로 로그인 했을 때 좋아요한 행사 리스트 받아오기
    func signIn(_ access: String, _ refresh: String, _ id: String) {
        accessToken = access
        refreshToken = refresh
        userID = id
    }
    
    func removeAll() {
        accessToken = ""
        refreshToken = ""
        userID = ""
        likeTitles = []
        likeIDs = []
    }
}
