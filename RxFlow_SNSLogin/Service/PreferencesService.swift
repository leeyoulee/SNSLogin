//
//  PreferencesService.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import RxSwift

protocol HasPreferencesService {
    var preferencesService: PreferencesService { get }
}

struct UserPreferences {
    private init () {}
    
    static let isLogined = "isLogined"
    static let loginUser = "loginUser"
}



class PreferencesService {
    /// 로그아웃했음을 저장
    func setNotIsLogined () {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserPreferences.isLogined)
    }
    /// 로그인 여부 가져옴
    func isLogined () -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: UserPreferences.isLogined)
    }
    /// 로그인 정보 저장
    func setUserInfo(info: UserInfo) {
        guard let data = try? JSONEncoder().encode(info) else { return }
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: UserPreferences.loginUser)
        defaults.set(true, forKey: UserPreferences.isLogined)
    }
    /// 로그인된 정보 가져옴
    func getUserInfo() -> UserInfo? {
        let defaults = UserDefaults.standard
        
        guard let encodedData = defaults.data(forKey: UserPreferences.loginUser), let data = try? JSONDecoder().decode(UserInfo.self, from: encodedData) else {
            return nil
        }
        
        return data
    }
    /// 로그인된 정보 삭제
    func removeUserInfo() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserPreferences.loginUser)
    }
}

extension PreferencesService: ReactiveCompatible {}

extension Reactive where Base: PreferencesService {
    var isLogined: Observable<Bool> {
        return UserDefaults.standard
            .rx
            .observe(Bool.self, UserPreferences.isLogined)
            .map { $0 ?? false }
    }
}
