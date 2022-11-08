//
//  ViewController.swift
//  TestSwift
//
//  Created by thebv on 27/07/2022.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton.init(frame: .init(x: 100, y: 100, width: 100, height: 50))
        button.setTitle("CLICK ME", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(clickMe), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    
    @objc func clickMe() {
        
        let vc = SecondViewController.init(nibName: "SecondViewController", bundle: Bundle.main)
        self.present(vc, animated: true) {
            
        }
    }


}

