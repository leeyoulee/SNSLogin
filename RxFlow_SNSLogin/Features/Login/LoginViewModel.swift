//
//  LoginViewModel.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 20/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa
import AuthenticationServices
import NaverThirdPartyLogin
import Alamofire
import KakaoOpenSDK

class LoginViewModel: NSObject, Stepper, ServicesViewModel {
    
    let steps = PublishRelay<Step>()
    typealias Services = HasPreferencesService
    
    var services: Services!
    
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    func setUserData(info: UserInfo) {
        self.services.preferencesService.setUserInfo(info: info)
    }
    
    func getUserData() -> UserInfo? {
        guard let user = self.services.preferencesService.getUserInfo() else { return nil }
        return user
    }
}

// MARK: - KAKAO LOGIN
extension LoginViewModel {
    func kakaoLogin() {
        guard let session = KOSession.shared() else {
            return
        }

        if session.isOpen() {
            session.close()
        }
        
        session.open(completionHandler: {(error) in
            if error == nil {
                if session.isOpen(){
                    print(session.token?.accessToken)

                    KOSessionTask.userMeTask(completion: { (error, result) -> Void in
                        if error != nil {
                            print("error\(error!)")
                        } else {
                            print("UserData : \(result)")
                            print("user.account?.isEmailVerified : \(result?.account?.isEmailVerified)")
                            let user = UserInfo(userName: result?.account?.profile?.nickname ?? "", userEmail: result?.account?.email ?? "", userPhoneNum: result?.account?.phoneNumber, userGender: "", userAge: result?.account?.birthyear, userProfileImage: result?.account?.profile?.profileImageURL, userIdentifier: result?.id, userType: .kakao)
                            self.setUserData(info: user)
                        }
                    })
                }
                    //로그인 실패
                else{
                    print("fail")
                }
            } else{
                print("error\(error!)")
            }
        })
    }
}

// MARK: - NAVER LOGIN
extension LoginViewModel: NaverThirdPartyLoginConnectionDelegate {
    
    func naverLoginSet() {
        self.loginInstance?.delegate = self
        self.loginInstance?.requestThirdPartyLogin()
    }
    
    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("[Success] : Success Naver Login")
        getNaverEmailFromURL()
    }
    
    // 접근 토큰 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        
    }
    
    // 로그아웃 할 경우 호출(토큰 삭제)
    public func oauth20ConnectionDidFinishDeleteToken() {
        loginInstance?.requestDeleteToken()
    }
    
    // 로그인에 실패했을 경우 호출, 모든 Error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] :", error.localizedDescription)
    }
    
    func getNaverEmailFromURL(){
        guard let loginConn = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
        guard let tokenType = loginConn.tokenType else { return }
        guard let accessToken = loginConn.accessToken else { return }
        
        let authorization = "\(tokenType) \(accessToken)"
        Alamofire.request("https://openapi.naver.com/v1/nid/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization" : authorization]).responseJSON { (response) in
            guard let result = response.result.value as? [String: Any] else {return}
            guard let object = result["response"] as? [String: Any] else {return}
            var birthday = ""
            var name = ""
            var email = ""
            
            // 가져올 데이터 중 사용자가 권한 허용을 안할 경우 빈값으로 채워주기위해 체크해줌
            if object.keys.contains("birthday"), let b = object["birthday"] as? String {
                birthday = b
            } else {
                birthday = ""
            }
            
            if object.keys.contains("name"), let n = object["name"] as? String {
                name = n
            } else {
                name = ""
            }
            
            if object.keys.contains("email"), let e = object["email"] as? String {
                email = e
            } else {
                email = ""
            }

            print("UserData : \(result)")
            let user = UserInfo(userName: name, userEmail: email, userPhoneNum: "", userGender: "", userAge: birthday, userProfileImage: nil, userIdentifier: "", userType: .naver)
            self.setUserData(info: user)
        }
    }
}

// MARK: - APPLE LOGIN
extension LoginViewModel: ASAuthorizationControllerDelegate {
    
    /// appleID 버튼뷰 생성
    @available(iOS 13.0, *)
    func setAppleLoginButtonView() -> ASAuthorizationAppleIDButton {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        return authorizationButton
    }
    
    // 로그인했던 계졍이 있을때 그 계정으로 로그인할 수 있도록함
    func performExistingAccountSetupFlows() {
        if #available(iOS 13.0, *) {
            let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                            ASAuthorizationPasswordProvider().createRequest()]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: requests)
            authorizationController.delegate = self
            //            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            print("iOS 13 이상에서만 사용 가능한 기능입니다.")
        }
    }
    
    @objc private func handleLogInWithAppleIDButtonPress() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email] // 이메일과 이름을 반드시 제공하도록 요청
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            //            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            print("iOS 13 이상에서만 사용 가능한 기능입니다.")
        }
    }
    
    /// 요청에 성공했을때 데이터 처리
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let userIdentifier = appleIDCredential.user
            print("UserData : \(userIdentifier)")
            
            // 처음 로그인할때는 이름,이메일,아이덴티 모두 제공
            if let fullName = appleIDCredential.fullName?.familyName,
                let givenName = appleIDCredential.fullName?.givenName, let email = appleIDCredential.email  {
                let user = UserInfo(userName: fullName + givenName, userEmail: email, userPhoneNum: "", userGender: "", userAge: "", userProfileImage: nil, userIdentifier: userIdentifier, userType: .apple)
                self.setUserData(info: user)
            }
            // 로그인 정보가 있을때는 아이덴티만 제공 -> 아이덴티로 서버에 저장된 이메일,이름을 가져와야함
            else {
                if let userInfo = self.getUserData(), userInfo.userIdentifier == userIdentifier {
                    let user = UserInfo(userName: userInfo.userName, userEmail: userInfo.userEmail, userPhoneNum: "", userGender: "", userAge: "", userProfileImage: nil, userIdentifier: userIdentifier, userType: .apple)
                    self.setUserData(info: user)
                }
            }
        default:
            break
        }
    }
    
    /// 요청에 실패했을때 에러처리
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

