//
//  SMSPrintViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 09/07/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork
import CountryPickerView

class SMSPrintViewController: UIViewController,UITextFieldDelegate,CountryPickerViewDelegate  {

    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var userCredTextField: UITextField!
    @IBOutlet weak var sendBtnOutlet: UIButton!
    
    let acceptableCharacters = "0123456789"
    var isSendBtnEnabled : Bool = false
    var previewTrasactionID : String = ""
    var selectedOption : String = ""
    var countryCode : String = "+1"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Send test results"

        switch selectedOption {
        case "SMS" :
            let countryPickerView = CountryPickerView(frame: CGRect(x: 2, y: 5, width: 120, height: 20))
            countryPickerView.delegate = self
            countryPickerView.dataSource = self
            
            let separatorView : UIView = UIView()
            separatorView.frame = CGRect(x: 125, y: 1, width: 1, height: 28)
            separatorView.backgroundColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            
            let countryCodeView : UIView = UIView()
            countryCodeView.frame = CGRect(x: 0, y: 0, width: 135, height: 30)
            countryCodeView.addSubview(countryPickerView)
            countryCodeView.addSubview(separatorView)
            
            userCredTextField.leftView = countryCodeView
            userCredTextField.leftViewMode = .always
            userCredTextField.delegate = self
            userCredTextField.keyboardType = .phonePad
            userCredTextField.addTarget(self, action: #selector(IMEIViewController.textFieldDidChange(_:)),
                                   for: UIControlEvents.editingChanged)
        case "Email" :
            let leftView : UIView = UIView()
            leftView.frame = CGRect(x: 0, y: 1, width: 5, height: 28)
            leftView.backgroundColor = UIColor.white

            userCredTextField.leftView = leftView
            userCredTextField.leftViewMode = .always

            userCredTextField.placeholder = "someone@example.com"
            sendBtnOutlet.isEnabled = true
            userInfo.text = "Please enter your email address to receive a copy of your test results."
        default: break
        }
        
        userCredTextField.layer.cornerRadius = 5.0
        userCredTextField.layer.borderColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        userCredTextField.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //TextField delegates
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 10 {
            isSendBtnEnabled = true
            sendBtnOutlet.isEnabled = true
        } else {
            if isSendBtnEnabled {
                isSendBtnEnabled = false
                sendBtnOutlet.isEnabled = false
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
        if (textField == self.userCredTextField) {
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
    
    //Country Picker Delegate
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        countryCode = country.phoneCode
        print(country.phoneCode)
    }

    // Button action
    
    @IBAction func cancelPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendResults(_ sender: Any) {
        DispatchQueue.main.async {
            self.userCredTextField.resignFirstResponder()
        }
        proceedToSendTestResults() //perform(#selector(SMSPrintViewController.proceedToSendTestResults), with: nil, afterDelay: 0.8)
    }
    
    @objc func proceedToSendTestResults() {
        switch selectedOption {
        case "SMS" :
            guard let phoneNumber =  userCredTextField.text else {
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter phone number to continue")
                }
                return
            }
            let phoneNumberWithCountryCode = countryCode + phoneNumber
            if ACDCUtilities.isValidPhoneNumber(phoneNumber: phoneNumber) {
                let subSeq = phoneNumberWithCountryCode.index(phoneNumberWithCountryCode.startIndex, offsetBy: 1)
                let trimmedString = phoneNumberWithCountryCode[subSeq...]
                let smsNumber = String(trimmedString)
                self.sendSMSRequestToServer(phoneNumber: smsNumber)
            } else {
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter a valid phone number")
                }
                return
            }
        case "Email" :
            guard let emailID =  userCredTextField.text else {
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter Email Id to continue")
                }
                return
            }
            if ACDCUtilities.isValidEmailId(testStr: emailID) {
                self.sendEmailRequestToServer(emailID: emailID, trasactionIdentifier: previewTrasactionID)
            } else {
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter a valid Email Id")
                }
                return
            }
        default : break
        }
    }
}

extension SMSPrintViewController {
    
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
                            ACDCUtilities.showMessage(title: "Alert", msg: "Your request is accepted by the server.")
                        }
                    } else {
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Sorry, server could not accept your request.")
                        }
                    }
                } catch  {
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
                var errorDescription = ""
                if let  errorDes = error?.localizedDescription {
                    errorDescription = errorDes
                    ACDCUtilities.showMessage(title: "ERROR", msg: errorDescription)
                }
            }
        }
    }
    
    func sendEmailRequestToServer(emailID: String, trasactionIdentifier: String) {
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
        }
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        
        acdcRequestAdapter.sendEmail(forEmailID: emailID, transactionID: trasactionIdentifier, successCallback: {(statusCode, responseResult) in
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
                            ACDCUtilities.showMessage(title: "Alert", msg: "Your request is accepted by the server.")
                        }
                    } else {
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
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
                var errorDescription = ""
                if let  errorDes = error?.localizedDescription {
                    errorDescription = errorDes
                    ACDCUtilities.showMessage(title: "ERROR", msg: errorDescription)
                }
            }
        }
    }
}

///Mark- Country Pickerview prefered countries
extension SMSPrintViewController: CountryPickerViewDataSource {
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
            var countries = [Country]()
            ["US", "IN"].forEach { code in
                if let country = countryPickerView.getCountryByCode(code) {
                    countries.append(country)
                }
            }
            return countries
        
    }
    
    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
            return "Select a Country "
       
    }
    
    func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
        return true
    }
    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return ""
    }
    
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        
        return .hidden
    }
    
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return true
    }
}
