//
//  CustomerResponseViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 08/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class CustomerResponseViewController: UIViewController,HamburgerMenuProtocol {

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
    @IBOutlet weak var evalAcceptedSwitch: UISwitch!
    @IBOutlet weak var deviceExchangeSwitch: UISwitch!

    
    var salesRepSelected : Bool = false
    var customerResSelected : Bool = false
    
    var customerRating: Int = 0
    var operatorRating: Int = 0
    

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

    // MARK: Hamburger menu delegate
    
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

    @IBAction func endSessionPressed(_ sender: Any) {
        endSessionWithFeedback()
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
        
        customerRating = selectedStar
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
        
        operatorRating = selectedStar
    }

    
    func terminateSession() {
        
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        //parameters to send
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String
        let inputSessionID = UserDefaults.standard.value(forKey: "SESSION_ID") as! String
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()

        acdcRequestAdapter.terminateACDCSession(sessionIdenfifier: inputSessionID, transactionIdentifier: inputTransactionID, successCallback: {(statusCode, responseResult) in
            
//            guard let dataResponse = responseResult else{
//                //error occured:Prompt alert
//                return
//            }
            //            do{
            //
            //
            //            }catch {
            //
            //            }
        }) { (error) in
            
        }
        
        
        
    }
    
    func endSessionWithFeedback() {
        
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        //parameters to send
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String
        let inputSessionID = UserDefaults.standard.value(forKey: "SESSION_ID") as! String
        let cusRating = String(self.customerRating)
        let opeRating = String(self.operatorRating)
        let evalAccepted = evalAcceptedSwitch.isOn
        let didExchangeDevice = deviceExchangeSwitch.isOn
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.sendCustomerRating(custmomerRating: cusRating, operatorRating: opeRating, evaluationAccepted: evalAccepted, deviceExchanged: didExchangeDevice, transactionIdentifier: inputTransactionID, sessionIdentifier: inputSessionID, successCallback: {(statusCode, responseResult) in
            guard let receivedStatusCode = statusCode else {
                //Status code should always exists
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                }
                return
            }
            
            if(receivedStatusCode == 200) {
                guard let dataResponse = responseResult else {
                    //error occured:Prompt alert
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Unexpected response received from server")
                    }
                    return
                }
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: [])
                    
                    guard let parsedResponse = (jsonResponse as? [String : Any]) else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                        return
                    }
                    
                    guard let successStatus = parsedResponse["status"] as? String else {
                        return
                    }
                    
                    if(successStatus.caseInsensitiveCompare("success") == ComparisonResult.orderedSame) {
                        DispatchQueue.main.async {
                                self.navigateToProductSelection()
                            
                        }
                    } else {
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Server responded with failed status.")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Could not parse response.")
                    }
                }
            } else {
                //status code not 200
                
                if(receivedStatusCode == 401){
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "Alert", msg: "Not Authorized!")
                    }
                }else if(ACDCResponseStatus.init(statusCode: receivedStatusCode) == .ServerError){
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "Error", msg: "Server error")
                    }
                } else {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "Error", msg: "Something went wrong. Received bad response.")
                    }
                }
                
            }
        }) { (error) in
            //Error
            DispatchQueue.main.async {
                
                if let  errorDes = error?.localizedDescription {
                    ACDCUtilities.showMessage(title: "ERROR", msg: errorDes)
                }
            }
        }
            
            
    }

    func navigateToProductSelection() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ModuleSelectionViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
}
