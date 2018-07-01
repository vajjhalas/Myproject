//
//  ViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 07/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicatorOutlet: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 2
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isAdditive = true
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = nil
        animation.toValue = 2 * 3.14
        activityIndicatorOutlet.layer.add(animation, forKey: "loader")

        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.showInitialViewController), userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func showInitialViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }

}

