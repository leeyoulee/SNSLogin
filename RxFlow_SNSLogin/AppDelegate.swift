//
//  AppDelegate.swift
//  RxFlow_SNSLogin
//
//  Created by 이유리 on 11/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import AuthenticationServices
import NaverThirdPartyLogin
import KakaoOpenSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let disposeBag = DisposeBag()
    var coordinator = FlowCoordinator()
    let preferencesService = PreferencesService()
    lazy var appServices = {
        return AppServices(preferencesService: self.preferencesService)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        guard let window = self.window else { return false }
        
        self.coordinator.rx.willNavigate.subscribe(onNext: { (flow, step) in
            print("will navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)
        
        self.coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)
        
        let appFlow = AppFlow(services: self.appServices)
        
        Flows.whenReady(flow1: appFlow) { root in
            window.rootViewController = root
        }
        
        self.coordinator.coordinate(flow: appFlow, with: AppStepper(withServices: self.appServices))
        
        // MARK: Naver Login
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isNaverAppOauthEnable = true //네이버 앱으로 인증(앱 설치)
        instance?.isInAppOauthEnable = true //사파리 뷰 컨트롤러에서 인증(앱 미설치)
        //네이버 앱이 없다면 사파리를 통해 인증 진행. 앱 인증과 사파리 인증이 둘 다 활성화되어 있다면 네이버 앱이 있는지 먼저 검사를 후 네이버 앱이 있다면 네이버 앱으로, 없으면 사파리를 통해 인증 진행
        instance?.isOnlyPortraitSupportedInIphone() //인증화면 세로 모드로만 사용
        instance?.serviceUrlScheme = kServiceAppUrlScheme // 콜백을 받을 URL Scheme
        instance?.consumerKey = kConsumerKey // 애플리케이션에서 사용하는 클라이언트 아이디
        instance?.consumerSecret = kConsumerSecret// 애플리케이션에서 사용하는 클라이언트 시크릿
        instance?.appName = kServiceAppName // 애플리케이션 이름
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        KOSession.handleDidEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // MARK: APPLE Login
        
        KOSession.handleDidBecomeActive()
        
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()

            appleIDProvider.getCredentialState(forUserID: (self.appServices.preferencesService.getUserInfo()?.userIdentifier) ?? "") { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    print("authorized")
                // The Apple ID credential is valid.
                case .revoked:
                    print("revoked")
                    self.appServices.preferencesService.setNotIsLogined()
                case .notFound:
                    print("notFound")
                default:
                    break
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Mark: Kakao, Naver Login
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        } else {
            let result = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
            print("\(result)")
            return result
        }
    }
    
}

struct AppServices: HasPreferencesService {
    let preferencesService: PreferencesService
}

