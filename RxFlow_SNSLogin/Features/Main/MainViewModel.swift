//
//  MainViewModel.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxSwift
import RxCocoa
import NaverThirdPartyLogin
import KakaoOpenSDK

class MainViewModel: ServicesViewModel, Stepper {
    
    let steps = PublishRelay<Step>()
    typealias Services = HasPreferencesService
    
    var isLoginedCheck = BehaviorRelay<Bool>(value: false)
    var loginedUser = BehaviorRelay<UserInfo?>(value: nil)
    let disposeBag = DisposeBag()
    
    var services: Services! {
        didSet {
            self.services
                .preferencesService.rx
                .isLogined
                .subscribe(onNext: { [weak self] value in
                    guard let `self` = self else { return }
                    if value, let user = self.services.preferencesService.getUserInfo() {
                        self.loginedUser.accept(user)
                    } else {
                        self.loginedUser.accept(nil)
                    }
                }).disposed(by: disposeBag)
        }
    }
    
    func removeUserData() {
        switch self.loginedUser.value?.userType {
        case .kakao:
            KOSessionTask.unlinkTask{success,_ in
                if success {
                    self.services.preferencesService.removeUserInfo()
                    self.services.preferencesService.setNotIsLogined()
                }
            }
            
            KOSession.shared()?.logoutAndClose { [weak self] (success, error) -> Void in
                if success {
                    guard let `self` = self else { return }
                    self.services.preferencesService.removeUserInfo()
                    self.services.preferencesService.setNotIsLogined()
                    
                }
            }
        case .naver:
            let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
            loginInstance?.resetToken()
            self.services.preferencesService.removeUserInfo()
            self.services.preferencesService.setNotIsLogined()
        case .apple:
            self.services.preferencesService.setNotIsLogined()
        case .isNotLogin:
            return
        case .none:
            self.services.preferencesService.setNotIsLogined()
        }
    }
    
}
