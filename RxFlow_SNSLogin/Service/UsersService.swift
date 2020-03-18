//
//  UsersService.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

protocol HasUsersService {
    var usersService: UsersService { get }
}

class UsersService {
    
    func loginUserInfo () -> [UserInfo] {
        let info = PreferencesService.getUserInfo()
        return
    }
    
}
