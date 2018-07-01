//
//  LoginViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 07/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userIDOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var loginBtnOutlet: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem

        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Please sign in"
        userIDOutlet.delegate = self
        passwordOutlet.delegate = self
        loginBtnOutlet.isEnabled = false
        loginBtnOutlet.alpha = 0.5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HamburgerMenuViewController") as! HamburgerMenuViewController
        vc.tableViewCellData = [["About","Contact","Feedback"]]
        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.navigationController?.navigationItem.title = "Menu"
        present(navController, animated: true, completion: nil)
    }
    
    func trimWhiteSpaces() {
        let trimmedUserID : String = (userIDOutlet.text?.trimmingCharacters(in: .whitespaces))!
        userIDOutlet.text = trimmedUserID
        let trimmedPasswordID : String = (passwordOutlet.text?.trimmingCharacters(in: .whitespaces))!
        passwordOutlet.text = trimmedPasswordID
    }

    // MARK: Keyboard Notifiactions
    
    @objc func keyboardWasShown(_ notification: Notification?) {
        if userIDOutlet.isFirstResponder || passwordOutlet.isFirstResponder {
            let info = notification?.userInfo
            let keyboardSize: CGSize? = (info?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
            let buttonOrigin: CGPoint = loginBtnOutlet.frame.origin
            let buttonHeight: CGFloat = loginBtnOutlet.frame.size.height
            var visibleRect: CGRect = view.frame
            visibleRect.size.height -= keyboardSize?.height ?? 0.0
            if !visibleRect.contains(buttonOrigin) {
                let scrollPoint = CGPoint(x: 0.0, y: buttonOrigin.y - visibleRect.size.height + buttonHeight)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification?) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: Text Field delegates

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.trimWhiteSpaces()
        
        if !(userIDOutlet.text == "") && !(passwordOutlet.text == "") {
            loginBtnOutlet.isEnabled = true
            loginBtnOutlet.alpha = 1.0
            print("CALLED== ")
        } else {
            loginBtnOutlet.isEnabled = false
            loginBtnOutlet.alpha = 0.5
        }
    }
    
    // MARK: Button Action

    @IBAction func loginPressed(_ sender: Any) {
        
        self.trimWhiteSpaces()
        if (userIDOutlet.text == "") || (passwordOutlet.text == "") {
            ACDCUtilities.showMessage(title: "Alert", msg: "Please provide valid input.")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ModuleSelectionViewController") as! ModuleSelectionViewController

        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return

        }
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()

        acdcRequestAdapter.loginUser(with: userIDOutlet.text!, usrPassword: passwordOutlet.text!) { (responseResult, error) in

            guard let dataResponse = responseResult, error == nil else {

                //error occured:Prompt alert
                print(error?.localizedDescription ?? "Response Error")
                return
            }

            do{
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                dataResponse, options: []) as! [String : Any]
                
                let dataDictionary = jsonResponse["data"] as! [String:Any]
                
                print("End result is \(jsonResponse)") //Response result
                print("Flags are>> \((dataDictionary["options"] as! [String]))")
                
                if(dataDictionary["storeId"] is String){
                    //what happens if nil
                    UserDefaults.standard.set(dataDictionary["storeId"], forKey: "STORE_ID")
                    UserDefaults.standard.synchronize()

                    vc.loadProductDataFor(flags: ((jsonResponse["data"] as! [String:Any])["options"] as! [String]))
                    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if(dataDictionary["storeId"] is NSNumber){
                    let storeIDValue = (dataDictionary["storeId"] as! NSNumber).stringValue
                    UserDefaults.standard.set(storeIDValue, forKey: "STORE_ID")
                    UserDefaults.standard.synchronize()

                    vc.loadProductDataFor(flags: ((jsonResponse["data"] as! [String:Any])["options"] as! [String]))
                    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    

                }
                

            } catch let parsingError {
                print("Error", parsingError)
            }

        }

    }
    
    @IBAction func forgetBtnPressed(_ sender: Any) {
        self.showALertss(title: "Please reset your password", body: "Please contact customer support.")
    }
    
    // MARK: Helper Methods
    func showALertss(title : String, body : String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            print("OK")
        })
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }
    
    
   
}



