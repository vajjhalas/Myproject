//
//  ReportProblemViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 18/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class ReportProblemViewController: UIViewController,UITextViewDelegate {

    
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
        print("kwenkkw")
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.proceedToNextTest()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        //TODO:Add guard statements for textview text presence
        reportProblemToServer()
        
        
    }
    
    @IBAction func tickMarkAction(_ sender: Any) {
        if (sender as AnyObject).tag == 1 {
            if crackDError.isSelected {
                crackDError.setImage(UIImage.init(named: "checkmark-active"), for: .normal)
            } else {
                crackDError.setImage(UIImage.init(named: "checkmark-inactive"), for: .normal)
            }
            crackDError.isSelected = !crackDError.isSelected
        } else {
            if crackNDError.isSelected {
                crackNDError.setImage(UIImage.init(named: "checkmark-active"), for: .normal)
            } else {
                crackNDError.setImage(UIImage.init(named: "checkmark-inactive"), for: .normal)
            }
            crackNDError.isSelected = !crackNDError.isSelected
        }
    }
    
    @objc func proceedToNextTest() {
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
            
            guard let dataResponse = responseResult else{
                //error occured:Prompt alert
                return
            }
                        do{
                            //TODO: guard for data status success string
                            //{"data":null,"message":null,"status":"success"}

                            /*
                             let alert = UIAlertController(title: "Thank you", message: "We have noted your concern. All necessary actions will be taken.", preferredStyle: .alert)
                             let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                             self.proceedToNextTest()
                             })
                             alert.addAction(defaultAction)
                             present(alert, animated: true)
                             */
            
                        }catch {
            
                        }
        }) { (error) in
            //Error
        }

    }
}
