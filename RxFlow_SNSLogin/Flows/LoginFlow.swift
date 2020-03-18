//
//  OnboardginFlow.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import UIKit.UINavigationController
import RxFlow
import RxSwift
import RxCocoa

class LoginFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.navigationBar.topItem?.title = "LoginVC"
        return viewController
    }()
    
    private let services: AppServices
    let disposeBag = DisposeBag()
    
    init(withServices services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .loginIsRequired:
            return navigationToLoginScreen()
        case .userIsLogIn:
            return .end(forwardToParentFlowWithStep: AppStep.loginIsComplete)
        default:
            return .none
        }
    }
    
    private func navigationToLoginScreen() -> FlowContributors {
        let loginViewModel = LoginViewModel()
        let loginViewController = LoginViewController.instantiate(withViewModel: loginViewModel,
                                                                  andServices: self.services)
        loginViewController.title = "Login"
        self.rootViewController.pushViewController(loginViewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: loginViewController, withNextStepper: loginViewController))
    }
    
}
