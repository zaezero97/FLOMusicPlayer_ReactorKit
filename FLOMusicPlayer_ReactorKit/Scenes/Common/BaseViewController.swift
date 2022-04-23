//
//  BaseViewController.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/23.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // 만약 스트림들을 해제하고싶을 때 disposeBag = DisposeBag() 하기 위해 var로 선언되어 있는 것 같다.
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
    }
}
