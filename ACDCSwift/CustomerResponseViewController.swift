//
//  CustomerResponseViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 08/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit

class CustomerResponseViewController: UIViewController {

    @IBOutlet weak var cFirstStar: UIButton!
    @IBOutlet weak var cSecondStar: UIButton!
    @IBOutlet weak var cThirdStar: UIButton!
    @IBOutlet weak var cFourthStar: UIButton!
    @IBOutlet weak var cFifthStar: UIButton!
    @IBOutlet weak var sFirstStar: UIButton!
    @IBOutlet weak var sSecondStar: UIButton!
    @IBOutlet weak var sThirdStar: UIButton!
    @IBOutlet weak var sFourthStar: UIButton!
    @IBOutlet weak var sFifthStar: UIButton!
    @IBOutlet weak var endSessionOutlet: UIButton!
    
    var salesRepSelected : Bool = false
    var customerResSelected : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Thank you!"
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showMenu() {
        print("kwenkkw")
    }

    @IBAction func endSessionPressed(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "ModuleSelectionViewController") as! ModuleSelectionViewController
//        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ModuleSelectionViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }

    }
    
    @IBAction func customerStarSelected(_ sender: Any) {
        if salesRepSelected {
            endSessionOutlet.alpha = 1.0
            endSessionOutlet.isUserInteractionEnabled = true
        }
        customerResSelected = true

        let selectedStar: Int = (sender as AnyObject).tag
        var allStars = [cFirstStar, cSecondStar, cThirdStar, cFourthStar, cFifthStar]
        for i in 0..<5 {
            if i < selectedStar {
                allStars[i]?.setImage(UIImage(named: "star-active"), for: .normal)
            } else {
                allStars[i]?.setImage(UIImage(named: "star-inactive"), for: .normal)
            }
        }
    }
    
    @IBAction func salesRepStarSelected(_ sender: Any) {
        if customerResSelected {
            endSessionOutlet.alpha = 1.0
            endSessionOutlet.isUserInteractionEnabled = true
        }
        salesRepSelected = true

        let selectedStar: Int = (sender as AnyObject).tag
        var allStars = [sFirstStar, sSecondStar, sThirdStar, sFourthStar, sFifthStar]
        for i in 0..<5 {
            if i < selectedStar {
                allStars[i]?.setImage(UIImage(named: "star-active"), for: .normal)
            } else {
                allStars[i]?.setImage(UIImage(named: "star-inactive"), for: .normal)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
