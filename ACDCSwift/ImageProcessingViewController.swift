//
//  ImageProcessingViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 08/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork



enum ImageProcessState : String {
    case InitiateCapture = "Initiating Capture..."
    case CapturingImage = "Capturing Image..."
    case ChamberImage = "Analysing Image..."
    case DVTImage = "Processed Image"
}

class ImageProcessingViewController: UIViewController {

    @IBOutlet weak var act1: UIActivityIndicatorView!
    @IBOutlet weak var act2: UIActivityIndicatorView!
    @IBOutlet weak var act3: UIActivityIndicatorView!
    @IBOutlet weak var progessVw1: UIView!
    @IBOutlet weak var progessVw2: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var IMEIString: UILabel!
    
    
    @IBOutlet weak var progressStatus: UILabel!
    @IBOutlet weak var capturedImageView: UIImageView!

    var ackIdentifier = "-1"
    var imageType : ImageProcessState = .InitiateCapture
    var imageQualifiedStatus = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = imageType.rawValue
        self.navigationItem.hidesBackButton = true
        
        imageType = .InitiateCapture
        act1.startAnimating()
        view1.isHidden = true
        
        let IMEINumber : String = UserDefaults.standard.object(forKey: "IMEI_TRANSACTION") as! String
        IMEIString.text = "IMEI : \(IMEINumber)"
   
        self.startImageCapture(for: "CaptureImage")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func captureChamberImageProcess() {
        imageType = .CapturingImage
        progressStatus.text = imageType.rawValue
        self.navigationItem.title = imageType.rawValue
        progessVw1.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        act1.stopAnimating()
        act2.startAnimating()
        view1.isHidden = false
        view1.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        view2.isHidden = true
        
    }

    @objc func captureDVTImageProcess() {
        imageType = .ChamberImage
        progressStatus.text = imageType.rawValue
        self.navigationItem.title = imageType.rawValue
        progessVw2.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        act2.stopAnimating()
        act3.startAnimating()
        view2.isHidden = false
        view2.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        view3.isHidden = true
    }
    
    @objc func proceedToTestResultsScreen() {
        act3.stopAnimating()
        view3.isHidden = false
        view3.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TestResultsViewController") as! TestResultsViewController
        vc.dvtImage = capturedImageView.image ?? UIImage.init(named: "chamber")
        vc.overallTestResultText = self.imageQualifiedStatus
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func startImageCapture(for command:String) {
        
        
        //parameters to send. //TODO:Add guardStatments
        let inputSessionID = UserDefaults.standard.value(forKey: "SESSION_ID") as! String

        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
       
        acdcRequestAdapter.startImageCapture(sessionIdentifier: inputSessionID, commandName: command, successCallback: {(statusCode, responseResult) in
            
            guard let dataResponse = responseResult else {
                
                //error occured:Prompt alert
                return
            }
            
            do {
                
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as! [String : Any]
                print("End result for product selection is \(jsonResponse)")
                
                
                //TODO: check if response is "success" String
                
                DispatchQueue.main.async {
                    self.captureChamberImageProcess()
                    self.pollForImageProcess()
                }
                
                
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }) { (error) in
            //Error
        }
    }


func pollForImageProcess() {

    //parameters to send. //TODO:Add guardStatments
    let inputSessionID = UserDefaults.standard.value(forKey: "SESSION_ID") as! String
  
    let acdcRequestAdapter = AcdcNetworkAdapter.shared()
    
    acdcRequestAdapter.fetchProgressOfImagecapture(acknowledgeID: ackIdentifier, sessionIdentifier: inputSessionID, successCallback: {(statusCode, responseResult) in
        
        guard let dataResponse = responseResult else {
            
            //error occured:Prompt alert
            if(responseResult == nil){
            self.pollForImageProcess()
            }
            return
        }
        
        do {
            
            
            //parse dataResponse
            //TODO:Are guard statements necessary while in try catch block?
            let jsonResponse = try JSONSerialization.jsonObject(with:
                dataResponse, options: []) as! [String : Any]
            //print("End result for polling image process is \(jsonResponse)")
            
            guard let ackIdentifier = jsonResponse["ackId"] else {
                //ackid missing
                return
            }
            
            guard let imageStatus = jsonResponse["status"] else {
                self.ackIdentifier = "-1"
                self.pollForImageProcess()
                return;
            }
            
            
           
        
            //update the acknowledgement identifier
            if (ackIdentifier is String){
                if((ackIdentifier as! String) != "-1"){
                    self.ackIdentifier = ackIdentifier as! String
                }
            }else if (ackIdentifier is NSNumber){
                if( ((ackIdentifier  as! NSNumber).stringValue) != "-1"){
                    self.ackIdentifier = (ackIdentifier  as! NSNumber).stringValue
                }
            }
            print("End result for polling image process status is \(imageStatus)")
            switch ((imageStatus as! String).uppercased()) {
                
            case "UNPROCESSED" :
                guard let commandDict = jsonResponse["command"] else {
                    self.pollForImageProcess()
                    return
                }
                guard let responseImageString = (commandDict as! [String: Any])["data"] else {
                    self.pollForImageProcess()
                    return
                }
                self.imageType = .ChamberImage
                let imageBase64SStr = responseImageString as! String
                self.updateImage(with: imageBase64SStr)
                self.pollForImageProcess()
                
            case "ADM_STARTED" :
                self.pollForImageProcess()
                return
            case "ADM_DONE" :
                self.pollForImageProcess()
                return
            case "FINAL_IMAGE_QUALIFIED" :
                guard let commandDict = jsonResponse["command"] else {
                    self.pollForImageProcess()
                    return;
                }
                guard let responseImageString = (commandDict as! [String: Any])["data"] else {
                    self.pollForImageProcess()
                    return
                }
                self.imageQualifiedStatus = "Qualified"
                self.imageType = .DVTImage
                let imageBase64SStr = responseImageString as! String
                self.updateImage(with: imageBase64SStr)
               // self.pollForImageProcess() //Poll for PDF
            case "FINAL_IMAGE_NOT_QUALIFIED" :
                guard let commandDict = jsonResponse["command"] else {
                    self.pollForImageProcess()
                    return;
                }
                guard let responseImageString = (commandDict as! [String: Any])["data"] else {
                    self.pollForImageProcess()
                    return
                }
                self.imageQualifiedStatus = "Not Qualified"
                self.imageType = .DVTImage
                let imageBase64SStr = responseImageString as! String
                self.updateImage(with: imageBase64SStr)
          
            case "PDF_DONE" :
                //need to call PDF creation API
                return

            case "TIMEOUT" :
                self.pollForImageProcess()
            case  "INVALID_SESSION" :
                //end session and move to module screen
                return
            case  "FAIL" :
                // an error occurred between server and chamber
                return
            //TODO:PDF call is yet to be implemented
            default :
                return
                
            }
            
        } catch let parsingError {
            print("Error", parsingError)
        }
    }) { (error) in
        //Error
        //TODO:  Timed out: HTTP request times out. Weak wifi or slow server?
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "ERROR", message: "Request Timed out. It may be due to slow network connection or unresponive server. Would you like to retry?", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { action in
                self.pollForImageProcess()
            })
            let popAction = UIAlertAction(title: "Back", style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(retryAction)
            alert.addAction(popAction)
            self.present(alert, animated: true)
        }
        
    }

    }
    
    func updateImage(with base64String:String) {
        
        let responseImageData = Data.init(base64Encoded: base64String)
        
        guard let recImageData = responseImageData else {
            //TODO: did not receive image. something is wrong.Prompt alert??
            return
        }
        let capturedImage = UIImage.init(data: recImageData)
        
        DispatchQueue.main.async {
            self.capturedImageView.image = capturedImage
            
            switch self.imageType {
            
            case .ChamberImage:
                self.captureDVTImageProcess()

            case .DVTImage:
                self.proceedToTestResultsScreen()
            default :
                return
            }
        }
    }
    
    func navigateToIMEIForANewTransaction() {
        
        if let viewControllers = self.navigationController?.viewControllers
        {
            if let imeiCtrl = viewControllers.first(where: {return $0 is IMEIViewController}) {
                
                self.navigationController?.popToViewController(imeiCtrl, animated: true)
            }
        }
    }
    
}

