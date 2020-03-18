//
//  AppStepper.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

class AppStepper: Stepper {
    
    let steps = PublishRelay<Step>()
    private let appServices: AppServices
    private let disposeBag = DisposeBag()
    
    init(withServices services: AppServices) {
        self.appServices = services
    }
    
    var initialStep: Step {
        return AppStep.mainIsRequired
    }
    
    func readyToEmitSteps() {
        self.appServices
            .preferencesService.rx
            .isLogined
            .map { $0 ? AppStep.loginIsComplete : AppStep.loginIsRequired }
            .bind(to: self.steps)
            .disposed(by: self.disposeBag)
    }
}
