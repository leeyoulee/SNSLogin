//
//  Step.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 11/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import RxFlow

enum AppStep: Step {
    // Login
    case userIsLogIn
    case loginIsRequired
    case loginIsComplete
    
    // Main
    case mainIsRequired
}
