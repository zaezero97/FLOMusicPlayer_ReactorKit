//
//  MusicPlayViewController.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/23.
//

import UIKit
import ReactorKit

final class MusicPlayViewController: BaseViewController, View {
    
    init(reactor: MusicPlayReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        
    }
    
    func bind(reactor: MusicPlayReactor) {
        
    }
}
