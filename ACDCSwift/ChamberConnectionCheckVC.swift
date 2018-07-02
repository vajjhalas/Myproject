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
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.establishConnectionWithChamber(chamberIdentifier: withChamberID, successCallback: {(statusCode, responseResult) in
            
            guard let receivedStatusCode = statusCode else {
                //Status code should always exists
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                }
                return
            }
            
            if(receivedStatusCode == 200) {
                
                guard let dataResponse = responseResult else {
                    //TODO:error occured:Prompt alert
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                    }
                    return
                }
                
                do{

                
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as! [String : String]
                print("End result for product selection is \(jsonResponse)")
                
                if((jsonResponse["type"])?.caseInsensitiveCompare("sid") == ComparisonResult.orderedSame) {
                    //store session ID
                    guard let sessionID = jsonResponse["value"] else{
                        //TODO: Prompt alert required?
                        print("Session ID NOT RECEIVED. SOMETHING IS WRONG")
                        return
                    }
                    
                    UserDefaults.standard.set(sessionID, forKey: "SESSION_ID")
                    UserDefaults.standard.synchronize()
                    
                    //session is established. Navigate to next screen
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ImageProcessingViewController") as! ImageProcessingViewController
                    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                    
                    self.navigationController?.pushViewController(vc, animated: true)

                    
                }else if(jsonResponse["type"]?.caseInsensitiveCompare("error") == ComparisonResult.orderedSame){
                    //TODO: Prompt alert if error required?
                    //TODO: Retry connection or fetch the chambers?
                    
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Could not connect to chamber.")
                    }
                    
                }
                
                } catch {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Could not parse response.")
                    }
                }
                
            }else {
                //status code not 200
                
                if(receivedStatusCode == 401){
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "Alert", msg: "Not Authorized!")
                    }
                }
            }
        }) { (error) in
            //Error
            DispatchQueue.main.async {
                
                var errorDescription = ""
                if let  errorDes = error?.localizedDescription {
                    errorDescription = errorDes
                    ACDCUtilities.showMessage(title: "ERROR", msg: errorDescription)
                }
            }
        }
        
    }
}
