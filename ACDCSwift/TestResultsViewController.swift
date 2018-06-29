//
//  TestResultsViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 08/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit

class TestResultsViewController: UIViewController,SendResultsProtocol,HamburgerMenuProtocol {

    @IBOutlet weak var sendResultsOutlet: UIButton!
    @IBOutlet weak var dvtImageView: UIImageView!
    
    var dataa : Data? = nil
    
    var dvtImage:UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Test results"
        self.navigationItem.hidesBackButton = true
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
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
        let alertController = UIAlertController(title: "Send test results", message: "Please enter your mobile number to receive a copy of your test results.", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "123-456-7890"
            textField.keyboardType = .numberPad
        })
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            print("sendAction")
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Canelled")
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
    }
    
    func handleEmail() {
        let alertController = UIAlertController(title: "Send test results", message: "Please enter your email address to receive a copy of your test results.", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "xxx@xxxxx.xxx"
        })
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            print("sendAction")
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Canelled")
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func handlePrint() {
        print("---handlePrint")
        let filePath: URL? = Bundle.main.url(forResource: "jjson", withExtension: "geojson")
        let stringPath = filePath?.absoluteString
        var data: Data? = nil
        if let aPath = URL(string: stringPath ?? "") {
            data = try! Data(contentsOf: aPath)
        }
        var jsonn = [String:Any]()

        if let aData = data {
            jsonn = try! JSONSerialization.jsonObject(with: aData, options: []) as! [String:Any]
        }
        
        let str = jsonn["data"] as? String
        
        dataa = Data.init(base64Encoded: str!)
//        if let aData = data {
//            dataa = Data(base64Encoded: dataarr!, options: .ignoreUnknownCharacters)
//        }
        //initWithData:data];
        print(dataa as Any)
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
