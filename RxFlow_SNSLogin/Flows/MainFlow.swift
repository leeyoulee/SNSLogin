//
//  MainFlow.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 12/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import UIKit
import RxFlow

//class MainFlow: Flow {
//    var root: Presentable {
//        return self.rootViewController
//    }
//    
//    let rootViewController = UITabBarController()
//    private let services: AppServices
//    
//    init(withServices services: AppServices) {
//        self.services = services
//    }
//    
//    deinit {
//        print("\(type(of: self)): \(#function)")
//    }
//    
//    func navigate(to step: Step) -> FlowContributors {
//        guard let step = step as? AppStep else { return .none }
//        
//        switch step {
//        case .mainIsRequired:
//            return navigateToMain()
//        default:
//            return .none
//        }
//    }
//    
//    private func navigateToMain() -> FlowContributors {
//        let wishlistStepper = WishlistStepper()
//        
//        let wishListFlow = WishlistFlow(withServices: self.services, andStepper: wishlistStepper)
//        let watchedFlow = WatchedFlow(withServices: self.services)
//        
//        Flows.whenReady(flow1: wishListFlow, flow2: watchedFlow) { [unowned self] (root1: UINavigationController, root2: UINavigationController) in
//            let tabBarItem1 = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), selectedImage: nil)
//            let tabBarItem2 = UITabBarItem(title: "Watched", image: UIImage(named: "watched"), selectedImage: nil)
//            root1.tabBarItem = tabBarItem1
//            root1.title = "Wishlist"
//            root2.tabBarItem = tabBarItem2
//            root2.title = "Watched"
//            
//            self.rootViewController.setViewControllers([root1, root2], animated: false)
//        }
//        
//        return .multiple(flowContributors: [.contribute(withNextPresentable: wishListFlow,
//                                                        withNextStepper: CompositeStepper(steppers: [OneStepper(withSingleStep: DemoStep.moviesAreRequired), wishlistStepper])),
//                                            .contribute(withNextPresentable: watchedFlow,
//                                                        withNextStepper: OneStepper(withSingleStep: DemoStep.moviesAreRequired))])
//    }
//}
