//
//  TestResultsViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 08/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class TestResultsViewController: UIViewController,SendResultsProtocol,HamburgerMenuProtocol {

    @IBOutlet weak var sendResultsOutlet: UIButton!
    @IBOutlet weak var dvtImageView: UIImageView!
    @IBOutlet weak var IMEIString: UILabel!
    @IBOutlet weak var overallTestResult: UILabel!
    @IBOutlet weak var resultImage: UIImageView!
    
    var dataa : Data? = nil
    
    var dvtImage:UIImage?
    var overallTestResultText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Test results"
        self.navigationItem.hidesBackButton = true
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let IMEINumber : String = UserDefaults.standard.object(forKey: "IMEI_TRANSACTION") as! String
        IMEIString.text = "IMEI : \(IMEINumber)"
        
        overallTestResult.text = overallTestResultText
        resultImage.image = (overallTestResultText == "Qualified") ? UIImage.init(named: "qualified") : UIImage.init(named: "unqualified")

        if (dvtImage != nil){
            
            dvtImageView.image = dvtImage
            
        }else {
            //Should not be the case
            //Prompt a message that image not found and hide all the buttons(Print, email and SMS)
        }
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
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomerResponseViewController") as! CustomerResponseViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func reportAProblem(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReportProblemViewController") as! ReportProblemViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sendResults(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SendResultsViewController") as! SendResultsViewController
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width:180.0,height:130.0)
        let popOverVC : UIPopoverPresentationController = vc.popoverPresentationController!
        popOverVC.permittedArrowDirections = .down
        popOverVC.sourceView = sendResultsOutlet
        popOverVC.sourceRect = CGRect(x:90.0,y:0.0,width:2.0,height:2.0)
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: SendResultsProtocol delegates
    func selectedService(selectedString: NSString) {
        self.dismiss(animated: true, completion: nil)
        
        if selectedString == "SMS" {
            self.handleSMS()
        } else if selectedString == "Email" {
            self.handleEmail()
        } else if selectedString == "Print" {
            self.handlePrint()
        }
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

    //MARK: Helper Methods
    
    func handleSMS() {
//        let alertController = UIAlertController(title: "Send test results", message: "Please enter your mobile number to receive a copy of your test results.", preferredStyle: .alert)
//        alertController.addTextField(configurationHandler: { textField in
//            textField.placeholder = "123-456-7890"
//            textField.keyboardType = .numberPad
//        })
//        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
//            print("sendAction")
//            guard let phoneNumber =  alertController.textFields?.first?.text else {
//                DispatchQueue.main.async {
//                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter phone number to continue")
//                }
//                return
//            }
//            if ACDCUtilities.isValidPhoneNumber(phoneNumber: phoneNumber) {
//                self.sendSMSRequestToServer(phoneNumber: phoneNumber)
//            } else {
//                DispatchQueue.main.async {
//                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter a valid phone number")
//                }
//                return
//            }
//        })
//        alertController.addAction(sendAction)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//            print("Canelled")
//        })
//        alertController.addAction(cancelAction)
//        present(alertController, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SMSViewController") as! SMSViewController
        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
        guard let transactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as? String else {
            DispatchQueue.main.async {
                ACDCUtilities.showMessage(title: "Alert", msg: "Problem in fetching transaction ID")
            }
            return
        }
        vc.previewTrasactionID = transactionID
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    func handleEmail() {
        let alertController = UIAlertController(title: "Alert", message: "Please enter your email address to receive a copy of your test results.", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "xxx@xxxxx.xxx"
        })
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            print("sendAction")
            guard let emailID =  alertController.textFields?.first?.text else {
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter email address to continue.")
                }
                return
            }
            if ACDCUtilities.isValidEmailId(testStr: emailID) {
                self.sendEmailRequestToServer(emailID: emailID)
            } else {
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter a valid Email ID")
                }
                return
            }
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Canelled")
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func handlePrint() {
        
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String

        PreviewPDFAPI.fetchPDFData(transactionID: inputTransactionID) { (PDFData, errorMessage) -> (Void) in
            guard let receivedPDFData = PDFData else {
                guard let receivedErrorMessage = errorMessage else {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong")
                    }
                    return
                }
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "ERROR", msg: receivedErrorMessage)
                }
                return
            }
            self.dataa = receivedPDFData
        }
        callPrinter()
    }

    func callPrinter() {
        let pc = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.orientation = .portrait
        printInfo.jobName = "Report"
        pc.printInfo = printInfo
        pc.showsPageRange = true
        pc.printingItem = dataa
        //[NSData dataWithContentsOfURL:documentsURL];
        // You can use here image or any data type to print.
        DispatchQueue.main.async(execute: {
            let completionHandler : UIPrintInteractionCompletionHandler = { printController, completed, error in
                if !completed && error != nil {
                    print("Print failed - domain: \((error as NSError?)?.domain ?? "") error code \(String(describing: error))")
                }
            }
            pc.present(from: CGRect(x: 0, y: 0, width: 300, height: 300), in: self.view, animated: true, completionHandler: completionHandler)
        });
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

//API calls

extension TestResultsViewController {
    func sendSMSRequestToServer(phoneNumber: String) {
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        //parameters to send
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        
        acdcRequestAdapter.sendSMS(forMoblNumber: phoneNumber, transactionID: inputTransactionID, successCallback: {(statusCode, responseResult) in
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
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
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
    
    func sendEmailRequestToServer(emailID: String) {
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        //parameters to send
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        
        acdcRequestAdapter.sendEmail(forEmailID: emailID, transactionID: inputTransactionID, successCallback: {(statusCode, responseResult) in
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
}

