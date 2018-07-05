//
//  SMSViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 04/07/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork
import CountryPickerView

class SMSViewController: UIViewController,UITextFieldDelegate,CountryPickerViewDelegate {

    @IBOutlet weak var smsTextField: UITextField!
    
    @IBOutlet weak var sendSMSOutlet: UIButton!
    
    let acceptableCharacters = "0123456789"
    var isSendBtnEnabled : Bool = false
    var previewTrasactionID : String = ""
    var countryCode : String = "+1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Send test results"

        let countryPickerView = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        countryPickerView.delegate = self
        smsTextField.leftView = countryPickerView
        smsTextField.leftViewMode = .always
        smsTextField.delegate = self
        smsTextField.keyboardType = .phonePad
        smsTextField.addTarget(self, action: #selector(IMEIViewController.textFieldDidChange(_:)),
                                for: UIControlEvents.editingChanged)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TextField delegates
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 10 {
            isSendBtnEnabled = true
            sendSMSOutlet.isEnabled = true
        } else {
            if isSendBtnEnabled {
                isSendBtnEnabled = false
                sendSMSOutlet.isEnabled = false
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.isEmpty) {
            return true
        }
        if textField.text?.count == 10 {
            return false
        }
        if (textField == self.smsTextField) {
            let cs = NSCharacterSet(charactersIn: self.acceptableCharacters)
            let filtered = string.components(separatedBy: cs as CharacterSet).filter { !$0.isEmpty }
            let str = filtered.joined(separator: "")//filtered.joinWithSeparator("")
            return (string != str)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func sendSMS(_ sender: Any) {
        guard let phoneNumber =  smsTextField.text else {
            DispatchQueue.main.async {
                ACDCUtilities.showMessage(title: "Alert", msg: "Please enter phone number to continue")
            }
            return
        }
        let phoneNumberWithCountryCode = countryCode + phoneNumber
        if ACDCUtilities.isValidPhoneNumber(phoneNumber: phoneNumber) {
            self.sendSMSRequestToServer(phoneNumber: phoneNumberWithCountryCode)
        } else {
            DispatchQueue.main.async {
                ACDCUtilities.showMessage(title: "Alert", msg: "Please enter a valid phone number")
            }
            return
        }
    }
    
    @IBAction func cancelPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func sendSMSRequestToServer(phoneNumber: String) {
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        
        acdcRequestAdapter.sendSMS(forMoblNumber: phoneNumber, transactionID: previewTrasactionID, successCallback: {(statusCode, responseResult) in
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
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Unexpected response received")
                    }
                    return
                }
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as! [String : Any]
                    
                    guard let successStatus = jsonResponse["status"] as? String else {
                        return
                    }
                    
                    if(successStatus.caseInsensitiveCompare("success") == ComparisonResult.orderedSame) {
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "Alert", msg: "Your request is accepted by the server.")
                        }
                    } else {
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Sorry, server could not accept your request.")
                        }
                    }
                } catch let parsingError {
                    print("Error", parsingError)
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

    //Country Picker Delegate
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        countryCode = country.phoneCode
        print(country.phoneCode)
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
