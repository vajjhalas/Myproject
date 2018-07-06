//
//  HistoryPreviewViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 21/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

class HistoryPreviewViewController: UIViewController {
    public enum ActionStyle {
        case print
        case activitySheet
        case customAction(() -> ())
    }
    
    private var document: PDFDocument!
    private var actionStyle = ActionStyle.print

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataa : Data? = nil
    var previewTrasactionID : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.white
        collectionView.register(PDFPageCollectionViewCell.self, forCellWithReuseIdentifier: "page")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendSMS(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SMSViewController") as! SMSViewController
        let navController = UINavigationController(rootViewController: vc)
        vc.previewTrasactionID = previewTrasactionID
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.preferredContentSize = CGSize(width: self.view.frame.width/2, height: self.view.frame.height/2)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        let alertController = UIAlertController(title: "Send test results", message: "Please enter your email address to receive a copy of your test results.", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "xxx@xxxxx.xxx"
        })
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            print("sendAction")
            guard let emailID =  alertController.textFields?.first?.text else {
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "Alert", msg: "Please enter Email ID to continue")
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
    
    @IBAction func printPDF(_ sender: Any) {
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
    
    @IBAction func dismissPreview(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: PDF Reader Related Methods

extension HistoryPreviewViewController {
    public class func createNew(with document: PDFDocument, title: String? = nil, actionButtonImage: UIImage? = nil, actionStyle: ActionStyle = .print, backButton: UIBarButtonItem? = nil, isThumbnailsEnabled: Bool = true, startPageIndex: Int = 0) -> HistoryPreviewViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "HistoryPreviewViewController") as! HistoryPreviewViewController
        controller.document = document
        controller.actionStyle = actionStyle
        
        if let title = title {
            controller.title = title
        } else {
            controller.title = document.fileName
        }
        return controller
    }
}

extension HistoryPreviewViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.pageCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! PDFPageCollectionViewCell
        cell.setup(indexPath.row, collectionViewBounds: collectionView.bounds, document: document, pageCollectionViewCellDelegate: self)
        return cell
    }
}

extension HistoryPreviewViewController: PDFPageCollectionViewCellDelegate {
    func handleSingleTap(_ cell: PDFPageCollectionViewCell, pdfPageView: PDFPageView) {
        var shouldHide: Bool {
            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
                return false
            }
            return !isNavigationBarHidden
        }
        UIView.animate(withDuration: 0.25) {
            self.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
        }
    }
}

extension HistoryPreviewViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 1, height: collectionView.frame.height)
    }
}

//API calls

extension HistoryPreviewViewController {
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
