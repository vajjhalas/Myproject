//
//  ChamberSelectionViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 01/07/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit


class ChamberSelectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,HamburgerMenuProtocol {
    
    var receivedChamberInfo : [[String:Any]] = [[:]]
    var chamberData : [ChamberInfo] = []
    var selectedChamberID : String = ""
    var selectedIndex : IndexPath?
    
    @IBOutlet weak var chambersCollectionView: UICollectionView!
    @IBOutlet weak var nextBtnOutlet: UIButton!
    @IBOutlet weak var collectionVwHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionVwWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Please choose an available chamber"
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        chambersCollectionView.delegate = self
        chambersCollectionView.dataSource = self
        chambersCollectionView.allowsSelection = true
        chambersCollectionView.allowsMultipleSelection = false

            for count in 0..<(receivedChamberInfo.count) {
                let chamberModel = ChamberInfo.init(jsonRecord: receivedChamberInfo[count])
                chamberData.append(chamberModel)
            }
            chambersCollectionView.reloadData()
            let multiplier  = Float(receivedChamberInfo.count)
            if multiplier > 4 {
                collectionVwWidth.constant = CGFloat(210.0 * 4)
                collectionVwHeight.constant = CGFloat(240.0 * 2)
            } else {
                collectionVwWidth.constant = CGFloat(210.0 * multiplier)
            }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HamburgerMenuViewController") as! HamburgerMenuViewController
        vc.delegate = self
        vc.tableViewCellData = [["About","Contact","Feedback"],["Home"],["Logout"]]
        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.navigationController?.navigationItem.title = "Menu"
        present(navController, animated: true, completion: nil)
        
    }

    // MARK: Hamburger menu delegates
    
    func popToSelectedOption(selectedOption: String) {
        
        if selectedOption == "Home" {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is ModuleSelectionViewController {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
        } else if selectedOption == "Logout" {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is LoginViewController {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
        }
    }

    // MARK: Button Actions

    @IBAction func nextButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChamberConnectionCheckVC") as! ChamberConnectionCheckVC
        vc.chamberIdentifier = selectedChamberID
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
     // MARK: COLLECTION VIEW STUFFS
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return receivedChamberInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "ChamberCollectionCell"
        let cell: ChamberSelectCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ChamberSelectCollectionViewCell
        cell?.layer.masksToBounds = true
        let chamb = chamberData[indexPath.row]
        cell?.chamberName.text = chamb.chamberName
        cell?.layer.borderWidth = 1.0
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.cornerRadius = 5.0

        if ((selectedIndex != nil) && (selectedIndex == indexPath)) {
            cell?.contentView.backgroundColor = UIColor.lightGray
        } else {
            cell?.contentView.backgroundColor = UIColor.white
        }
        
        if chamb.chamberStatus.uppercased() != "FREE" {
            cell?.chamberStatus.text = "Status : \((chamb.chamberStatus))"
            cell?.alpha = 0.5
            cell?.isUserInteractionEnabled = false
        } else {
            cell?.chamberStatus.text = "Status : Available"//If server is sending the status as "FREE" need to display as "Available"
            cell?.alpha = 1.0
            cell?.isUserInteractionEnabled = true
        }
        
        return cell!
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (selectedIndex == nil) {
            return
        }
        
        if(selectedIndex == indexPath) {
            cell.contentView.backgroundColor = UIColor.lightGray
        } else {
            cell.contentView.backgroundColor = UIColor.white
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        nextBtnOutlet.alpha = 1.0
        nextBtnOutlet.isUserInteractionEnabled = true
        let cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        cell.contentView.backgroundColor = UIColor.lightGray
        cell.isSelected = true
        selectedChamberID = chamberData[indexPath.row].chamberIdentifier
        selectedIndex = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.white
    }
}
