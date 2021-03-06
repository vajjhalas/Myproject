//
//  ChamberConnectionCheckVC.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 07/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class ChamberConnectionCheckVC: UIViewController,HamburgerMenuProtocol {

    var chamberIdentifier:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Insert the device into the chamber"
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

    @IBAction func startButtonPressed(_ sender: Any) {

        guard let aChamberID = self.chamberIdentifier, !(aChamberID.isEmpty) else {
            return
        }
        self.connectToChamber(withChamberID: aChamberID)
    }
    
    func connectToChamber(withChamberID:String) {
        
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        //parameters to send
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String

        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.establishConnectionWithChamber(chamberIdentifier: withChamberID, transactionIdentifier: inputTransactionID, successCallback: {(statusCode, responseResult) in
            
            guard let receivedStatusCode = statusCode else {
                //Status code should always exists
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                }
                return
            }
            
            if(receivedStatusCode == 200) {
                
                guard let dataResponse = responseResult else {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                    }
                    return
                }
                
                do{
                
                //parse dataResponse
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                    guard let parsedResponse = jsonResponse as? [String : Any] else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                        return
                    }
                    
                    guard let receivedType = parsedResponse["type"] as? String else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                        return
                    }
                    
                    
                if(receivedType.caseInsensitiveCompare("sid") == ComparisonResult.orderedSame) {
                    //store session ID
                    guard let sessionID = parsedResponse["value"] else{
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Session ID not received.")
                        }
                        return
                    }
                    
                    UserDefaults.standard.set(sessionID, forKey: "SESSION_ID")
                    UserDefaults.standard.synchronize()
                    
                    //session is established. Navigate to next screen
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "ImageProcessingViewController") as! ImageProcessingViewController
                        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    return
                }else if(receivedType.caseInsensitiveCompare("error") == ComparisonResult.orderedSame){
                    
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Alert", message: "Chamber is not free. Please try again.", preferredStyle: .alert)
                        let popAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.navigateToIMEIForListOfChambers()
                        })
                        alert.addAction(popAction)
                        self.present(alert, animated: true)
                    }
                    return

                    
                }else if(receivedType.caseInsensitiveCompare("BUSY") == ComparisonResult.orderedSame){
                
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Alert", message: "Chamber is not free. Please try again.", preferredStyle: .alert)
                        let popAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.navigateToIMEIForListOfChambers()
                        })
                        alert.addAction(popAction)
                        self.present(alert, animated: true)
                    }
                    return
                    
                }else {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                    }
                    }
                
                } catch {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "could not parse response.")
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
    
    func navigateToIMEIForListOfChambers() {
        
        if let viewControllers = self.navigationController?.viewControllers
        {
            if let imeiCtrl = viewControllers.first(where: {return $0 is IMEIViewController}) {
                
                self.navigationController?.popToViewController(imeiCtrl, animated: true)
            }
        }
    }
}
