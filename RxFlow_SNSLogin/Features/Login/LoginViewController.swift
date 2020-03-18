//
//  LoginViewController.swift
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
import AuthenticationServices
import NaverThirdPartyLogin
import Alamofire
import KakaoOpenSDK

class LoginViewController: UIViewController, StoryboardBased, Stepper, ViewModelBased {
    
    @IBOutlet weak var kakaoLoginButton: KOLoginButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIView!
    
    let steps = PublishRelay<Step>()
    var viewModel: LoginViewModel!
//    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kakaoLoginButtonEvent()
        self.naverLoginButtonEvent()
        
        // 애플로그인 버튼 버전 체크
        if #available(iOS 13.0, *) {
            self.appleLoginButton.addSubview(self.viewModel.setAppleLoginButtonView())
        } else {
            self.appleLoginButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        performExistingAccountSetupFlows()
    }
    
}
// MARK: - Button Event
extension LoginViewController {
    // 카카오
    func kakaoLoginButtonEvent() {
        self.kakaoLoginButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.kakaoLogin()
        }).disposed(by: disposeBag)
    }
    
    // 네이버
    func naverLoginButtonEvent() {
        self.naverLoginButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.naverLoginSet()
        }).disposed(by: disposeBag)
    }
}

//extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
//    @available(iOS 13.0, *)
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//}
