//
//  MainViewController.swift
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

class MainViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userData: UILabel!
    
    var viewModel: MainViewModel!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel else { return }

        // UI 바인딩
        viewModel.loginedUser.subscribe(onNext: { [weak self] user in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.userName?.text = user?.userName ?? ""
                self.userEmail?.text = user?.userEmail ?? ""
                self.userData?.text = user?.userIdentifier ?? ""
            }
        }).disposed(by: disposeBag)
        
        // logoutButton누르면 정보삭제
        self.logoutButton.rx.tap.subscribe({ [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.removeUserData()
        }).disposed(by: disposeBag)
    }
    
}
