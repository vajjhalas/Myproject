//
//  ReportProblemViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 18/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class ReportProblemViewController: UIViewController,UITextViewDelegate,HamburgerMenuProtocol {

    
    @IBOutlet weak var feedbackTextView: UITextView!
    
    @IBOutlet weak var sendFeedbackOutlet: UIButton!
    @IBOutlet weak var crackNDError: UIButton!
    @IBOutlet weak var crackDError: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Report a Problem"
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem

        feedbackTextView.delegate = self
        feedbackTextView.textColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.borderColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        feedbackTextView.text = "Please include a detailed description of the problem of your suggestion."

        sendFeedbackOutlet.alpha = 0.5
        sendFeedbackOutlet.isUserInteractionEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
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

    // Button Actions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.popToPreviousCtrl()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        reportProblemToServer()
    }
    
    @IBAction func tickMarkAction(_ sender: Any) {
        if (sender as AnyObject).tag == 1 {
            if !crackDError.isSelected {
                crackDError.setImage(UIImage.init(named: "checkmark-active"), for: .normal)
            } else {
                crackDError.setImage(UIImage.init(named: "checkmark-inactive"), for: .normal)
            }
            crackDError.isSelected = !crackDError.isSelected
        } else {
            if !crackNDError.isSelected {
                crackNDError.setImage(UIImage.init(named: "checkmark-active"), for: .normal)
            } else {
                crackNDError.setImage(UIImage.init(named: "checkmark-inactive"), for: .normal)
            }
            crackNDError.isSelected = !crackNDError.isSelected
        }
    }
    
    @objc func popToPreviousCtrl() {
        self.navigationController?.popViewController(animated: true)
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Please include a detailed description of the problem of your suggestion.") {
            feedbackTextView.textColor = UIColor.black
            feedbackTextView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 1 {
            sendFeedbackOutlet.alpha = 1.0
            sendFeedbackOutlet.isUserInteractionEnabled = true
        } else if textView.text.count == 0 {
            sendFeedbackOutlet.alpha = 0.5
            sendFeedbackOutlet.isUserInteractionEnabled = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
    }
    
}

//API calls
extension ReportProblemViewController {
    
    func reportProblemToServer() {
        
        
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        //parameters to send
        let issueText = feedbackTextView.text!
        let isCrackPresentNotDetected = crackDError.isSelected
        let isCrackAbsentDetected = crackNDError.isSelected
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String

        let acdcRequestAdapter = AcdcNetworkAdapter.shared()

        acdcRequestAdapter.reportAProblem(issueText: issueText, crackNotDetected: isCrackPresentNotDetected, crackWrongDetected: isCrackAbsentDetected, transactionIdentifier: inputTransactionID, successCallback: {(statusCode, responseResult) in
            
            guard let receivedStatusCode = statusCode else {
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
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: [])
                        
                    guard let parsedResponse = jsonResponse as? [String : Any] else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                        return
                    }
                    
                    guard let dataStatus = parsedResponse["status"] as? String else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                        return
                    }

                    if(dataStatus.caseInsensitiveCompare("success") == ComparisonResult.orderedSame) {
                        let alert = UIAlertController(title: "Thank you", message: "We have noted your concern. All necessary actions will be taken.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.popToPreviousCtrl()
                        })
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true)
                    } else {
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong.")
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
}
