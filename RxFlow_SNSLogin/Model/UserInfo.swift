//
//  UserInfo.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct UserInfo: Codable {
    var userName:           String
    var userEmail:          String
    var userPhoneNum:       String?
    var userGender:         String?
    var userAge:            String?
    var userProfileImage:   URL?
    var userIdentifier:     String?
    var userType:           LoginType
    
    init(userName: String, userEmail: String, userPhoneNum: String?, userGender: String?, userAge: String?, userProfileImage: URL?, userIdentifier: String?, userType: LoginType) {
        self.userName = userName
        self.userEmail = userEmail
        self.userPhoneNum = userPhoneNum
        self.userGender = userGender
        self.userAge = userAge
        self.userProfileImage = userProfileImage
        self.userIdentifier = userIdentifier
        self.userType = userType
    }
    
    enum CodingKeys : String, CodingKey {
        case userName
        case userEmail
        case userPhoneNum 
        case userGender
        case userAge
        case userProfileImage
        case userIdentifier
        case userType
    }
    
    init(from decoder: Decoder) throws {
        let container          = try decoder.container(keyedBy: CodingKeys.self)
        userName               = try container.decode(String.self, forKey: .userName)
        userEmail              = try container.decode(String.self, forKey: .userEmail)
        userPhoneNum           = try container.decodeIfPresent(String.self, forKey: .userPhoneNum)
        userGender             = try container.decodeIfPresent(String.self, forKey: .userGender)
        userAge                = try container.decodeIfPresent(String.self, forKey: .userAge)
        userProfileImage       = try container.decodeIfPresent(URL.self, forKey: .userProfileImage)
        userIdentifier         = try container.decodeIfPresent(String.self, forKey: .userIdentifier)
        userType               = try container.decode(LoginType.self, forKey: .userType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userName, forKey: .userName)
        try container.encode(self.userEmail, forKey: .userEmail)
        try container.encode(self.userPhoneNum, forKey: .userPhoneNum)
        try container.encode(self.userGender, forKey: .userGender)
        try container.encode(self.userAge, forKey: .userAge)
        try container.encode(self.userProfileImage, forKey: .userProfileImage)
        try container.encode(self.userIdentifier, forKey: .userIdentifier)
        try container.encode(self.userType, forKey: .userType)
    }
    
    enum LoginType: String, Codable {
        case kakao
        case naver
        case apple
        case isNotLogin
    }
}
