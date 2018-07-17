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
    @IBOutlet weak var programNameLabel: UILabel!

    
    var receivedPdfData : Data? = nil
    
    var dvtImage:UIImage?
    var overallTestResultText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Test results"
        self.navigationItem.hidesBackButton = true
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let IMEINumber : String = (UserDefaults.standard.object(forKey: "IMEI_TRANSACTION") as? String) ?? ""
        IMEIString.text = "IMEI : \(IMEINumber)"
        
        let programName : String = (UserDefaults.standard.object(forKey: "SELECTED_PROGRAM") as? String) ?? ""

        programNameLabel.text = "Program : \(programName)"
        
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SMSPrintViewController") as! SMSPrintViewController
        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
        guard let transactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as? String else {
            DispatchQueue.main.async {
                ACDCUtilities.showMessage(title: "Alert", msg: "Problem in fetching transaction ID")
            }
            return
        }
        vc.selectedOption = "SMS"
        vc.previewTrasactionID = transactionID
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.preferredContentSize = CGSize(width: self.view.frame.width/2, height: self.view.frame.height/2)
        present(navController, animated: true, completion: nil)
    }
    
    func handleEmail() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SMSPrintViewController") as! SMSPrintViewController
        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
        guard let transactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as? String else {
            DispatchQueue.main.async {
                ACDCUtilities.showMessage(title: "Alert", msg: "Problem in fetching transaction ID")
            }
            return
        }
        vc.selectedOption = "Email"
        vc.previewTrasactionID = transactionID
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.preferredContentSize = CGSize(width: self.view.frame.width/2, height: self.view.frame.height/2)
        present(navController, animated: true, completion: nil)
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
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Error occured in receiving pdf data.")
                    }
                    return
                }
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "ERROR", msg: receivedErrorMessage)
                }
                return
            }
            self.receivedPdfData = receivedPDFData
            
            DispatchQueue.main.async {
                self.callPrinter()
            }
        }
    }

    func callPrinter() {
        let pc = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.orientation = .portrait
        printInfo.jobName = "Report"
        pc.printInfo = printInfo
        pc.showsPageRange = true
        pc.printingItem = receivedPdfData
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
 }

