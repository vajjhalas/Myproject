//
//  ChamberConnectionCheckVC.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 07/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class ChamberConnectionCheckVC: UIViewController {

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
        print("kwenkkw")
    }

    @IBAction func startButtonPressed(_ sender: Any) {

        guard let aChamberID = self.chamberIdentifier, !(aChamberID.isEmpty) else {
            return
        }
        self.connectToChamber(withChamberID: aChamberID)
    }
    
    func connectToChamber(withChamberID:String) {
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.establishConnectionWithChamber(chamberIdentifier: withChamberID) { (responseResult, error) in
            
            guard let dataResponse = responseResult, error == nil else {
                
                //error occured:Prompt alert
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do {
                
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
                    
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
            
        }
    }
}
