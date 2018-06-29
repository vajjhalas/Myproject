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
    case ImageCapture
    case ChamberImage
    case DVTImage
}

class ImageProcessingViewController: UIViewController {

    @IBOutlet weak var act1: UIActivityIndicatorView!
    @IBOutlet weak var act2: UIActivityIndicatorView!
    @IBOutlet weak var act3: UIActivityIndicatorView!
    @IBOutlet weak var act4: UIActivityIndicatorView!
    @IBOutlet weak var progessVw1: UIView!
    @IBOutlet weak var progessVw2: UIView!
    @IBOutlet weak var progessVw3: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!

    @IBOutlet weak var capturedImageView: UIImageView!

    
  
    
    var ackIdentifier = "-1"
    var imageType : ImageProcessState = .ImageCapture

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Capturing Image"
        self.navigationItem.hidesBackButton = true
        
        imageType = .ImageCapture
        act1.startAnimating()
        view1.isHidden = true
   
        self.startImageCapture()
    }

    @objc func continueToNextStage1() {
        progessVw1.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        act1.stopAnimating()
        act2.startAnimating()
        view1.isHidden = false
        view1.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        view2.isHidden = true
    }

    @objc func continueToNextStage2() {
        progessVw2.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        act2.stopAnimating()
        act3.startAnimating()
        view2.isHidden = false
        view2.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        view3.isHidden = true
    }
    
    @objc func continueToNextStage3() {
        progessVw3.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        act3.stopAnimating()
        act4.startAnimating()
        view3.isHidden = false
        view3.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        view4.isHidden = true
        //TODO: this stage is not required. Review?
        perform(#selector(self.continueToNextStage4), with: nil, afterDelay: 1.0)
    }
    
    @objc func continueToNextStage4() {
        act4.stopAnimating()
        view4.isHidden = false
        view4.backgroundColor = UIColor.init(red: 226.0/255.0, green: 0.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        perform(#selector(self.proceedToNextCtrl), with: nil, afterDelay: 3.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func proceedToNextCtrl() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TestResultsViewController") as! TestResultsViewController
        vc.dvtImage = capturedImageView.image
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func startImageCapture() {
        
        
        //parameters to send. //TODO:Add guardStatments
        let inputSessionID = UserDefaults.standard.value(forKey: "SESSION_ID") as! String

        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
       
        acdcRequestAdapter.startImageCapture(sessionIdentifier: inputSessionID, commandName: "CaptureImage") { (responseResult, error) in
            
            guard let dataResponse = responseResult, error == nil else {
                
                //error occured:Prompt alert
                print(error?.localizedDescription ?? "Response Error")
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
                    self.continueToNextStage1()
                    self.pollForImageProcess()
                }
                
                
                
            } catch let parsingError {
                print("Error", parsingError)
            }
            
        }
    }


func pollForImageProcess() {
    
    
    //parameters to send. //TODO:Add guardStatments
    let inputSessionID = UserDefaults.standard.value(forKey: "SESSION_ID") as! String
  
    let acdcRequestAdapter = AcdcNetworkAdapter.shared()
    
    acdcRequestAdapter.fetchProgressOfImagecapture(acknowledgeID: ackIdentifier, sessionIdentifier: inputSessionID) { (responseResult, error) in
        
        guard let dataResponse = responseResult, error == nil else {
            
            //error occured:Prompt alert
            print(error?.localizedDescription ?? "Response Error")
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
            print("End result for polling image process is \(jsonResponse)")
            //TODO:Are guard statements necessary while in try catch block?
            let imageBase64SStr = (jsonResponse["command"] as! [String: Any])["data"] as! String
            let responseImageData = Data.init(base64Encoded: imageBase64SStr)
            
            guard let recImageData = responseImageData else {
                //TODO: did not receive image. something is wrong.Prompt alert??
                return
            }
            let capturedImage = UIImage.init(data: recImageData)
            
            
            DispatchQueue.main.async {
                self.capturedImageView.image = capturedImage
              
                switch self.imageType {
                case .ImageCapture:
                    self.imageType = .ChamberImage
                    self.continueToNextStage2()
                    self.pollForImageProcess()//Poll for DVT image
                case .ChamberImage:
                    self.imageType = .DVTImage
                    self.continueToNextStage3()
                case .DVTImage:
                    self.imageType = .DVTImage
                }
               
                
            }
            
            //if we get image
            
            
        } catch let parsingError {
            print("Error", parsingError)
        }
        
    }

    }
    
}

