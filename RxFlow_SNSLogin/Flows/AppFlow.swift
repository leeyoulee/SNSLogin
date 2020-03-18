//
//  AppFlow.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import UIKit
import RxFlow
import RxCocoa
import RxSwift

class AppFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    private let services: AppServices
    
    init(services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .mainIsRequired:
            return navigationToMainScreen()
        case .loginIsRequired:
            return navigationToLoginScreen()
        case .loginIsComplete:
            return self.dismissLoginScreen()
        default:
            return .none
        }
    }
    
    private func navigationToMainScreen() -> FlowContributors {
        let mainViewModel = MainViewModel()
        let mainViewController = MainViewController.instantiate(withViewModel: mainViewModel,
                                                                andServices: self.services)
        
        mainViewController.title = "main"
        self.rootViewController.pushViewController(mainViewController, animated: false)
        
        return .one(flowContributor: .contribute(withNextPresentable: mainViewController,
                                                 withNextStepper: mainViewModel))
    }
    
    private func navigationToLoginScreen() -> FlowContributors {
        let loginFlow = LoginFlow(withServices: self.services)
        
        Flows.whenReady(flow1: loginFlow) { [unowned self] root in
            DispatchQueue.main.async {
                self.rootViewController.show(root, sender: nil)
            }
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: loginFlow,
                                                 withNextStepper: OneStepper(withSingleStep: AppStep.loginIsRequired)))
    }
    
    private func dismissLoginScreen() -> FlowContributors {
        if let onboardingViewController = self.rootViewController.presentedViewController {
            self.rootViewController.reloadInputViews()
            onboardingViewController.dismiss(animated: true)
        }
        return .none
    }
}
