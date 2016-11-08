//
//  ViewController.swift
//  SwiftNavigationController
//
//  Created by 李海权 on 2016/11/8.
//  Copyright © 2016年 李海权. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button:UIButton = UIButton.init(type: UIButtonType.system)
        button.frame = CGRect.init(x: 50, y: 150, width: UIScreen.main.bounds.size.width - 100, height: 300)
        button.backgroundColor = UIColor.green
        button.addTarget(self, action: #selector(buttonAction(_ :)), for: UIControlEvents.touchUpInside)
        button.setTitle("点击进入界面", for: UIControlState.normal)
        self.view.addSubview(button)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func buttonAction(_ button:UIButton) -> Void {
        let vc:SecondViewController = SecondViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

