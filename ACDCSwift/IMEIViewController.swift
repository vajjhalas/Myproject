//
//  IMEIViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 07/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import SpreadsheetView
import AcdcNetwork

class IMEIViewController: UIViewController, SpreadsheetViewDelegate, SpreadsheetViewDataSource, UITextFieldDelegate, HamburgerMenuProtocol {

    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var showHistoryOutlet: UIButton!
    @IBOutlet weak var IMEItextField: UITextField!
    @IBOutlet weak var spreadSheetVw: SpreadsheetView!
    @IBOutlet weak var spreadSheetHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorMessageOutlet: UILabel!
    var json = [String:AnyObject]()
//    var elements : NSMutableArray = NSMutableArray()
    
    var PDFDataForPrint : Data? = nil

    var recordsArray:[HistoryRecord] = []
    
    let acceptableCharacters = "0123456789"
    let topRowColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
    let evenRowColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    let oddRowColor: UIColor = .white
    var isHistoryNextBtnEnabled : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IMEItextField.delegate = self
        self.navigationItem.title = "Please enter a device ID"
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        spreadSheetVw.isHidden = true
        spreadSheetVw.dataSource = self
        spreadSheetVw.delegate = self
        spreadSheetVw.layer.borderColor = UIColor.gray.cgColor
        spreadSheetVw.layer.borderWidth = 1.0
        
        spreadSheetVw.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        spreadSheetVw.intercellSpacing = CGSize(width: 1, height: 1)
       // spreadSheetVw.gridStyle = .solid(width: 1.0, color: .gray)
        spreadSheetVw.bounces = false
        spreadSheetVw.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
        spreadSheetVw.register(ResultCell.self, forCellWithReuseIdentifier: String(describing: ResultCell.self))

//        IMEItextField.text = "352066060926230"
        IMEItextField.addTarget(self, action: #selector(IMEIViewController.textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 15 {
            isHistoryNextBtnEnabled = true
            showHistoryOutlet.isEnabled = true
            nextButtonOutlet.isEnabled = true
        } else {
            if isHistoryNextBtnEnabled {
                isHistoryNextBtnEnabled = false
                showHistoryOutlet.isEnabled = false
                nextButtonOutlet.isEnabled = false
            }
        }
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

    func dateFromMillisecinds(timeInMilliseconds:String) ->  String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeInMilliSec : Double = Double(timeInMilliseconds)!
        let date = Date(timeIntervalSince1970: timeInMilliSec / 1000.0)
        let dateString = dateFormat.string(from: date)
        let timestamp = "\(dateString)"
        return timestamp
    }
    
    func validateIMEI(imeiString : String) -> Bool {
        var oddSum : Int = 0
        var evenSum : Int = 0
        
        var index : UInt = 0
        for (_,ch) in imeiString.enumerated() {
            print("CHAR \(ch)");
            let digit : Int = Int(String(ch))!
            if (index % 2) == 0{
                evenSum += digit
            }
            else {
                oddSum += (digit / 5) + (2 * digit) % 10
            }
            index += 1
        }
        return (oddSum + evenSum) % 10 == 0
    }
    
    // MARK: Hamburger menu delegates

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

    // MARK: Text Field delegates

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.isEmpty) {
            return true
        }
        if textField.text?.count == 15 {
            return false
        }
        if (textField == self.IMEItextField) {
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

    // MARK: Button Action

    @IBAction func IMEINextPressed(_ sender: Any) {
        
        ///TODO:Validate IMEI and then call API
        let IMEINum = IMEItextField.text

        if self.validateIMEI(imeiString: IMEINum!) {
            errorMessageOutlet.isHidden = true
            self.getListOfChambers()
        } else {
            errorMessageOutlet.isHidden = false
            errorMessageOutlet.text = "Enter Valid IMEI number."
        }
    }

    @IBAction func showHistoryPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
//        let smallPDFDocumentName = "samplePDF"
//        if let doc = document(smallPDFDocumentName) {
//            showDocument(doc)
//        } else {
//            print("Document named \(smallPDFDocumentName) not found in the file system")
//        }
//return
        let IMEINum = IMEItextField.text

        if self.validateIMEI(imeiString: IMEINum!) {
            errorMessageOutlet.isHidden = true
            self.getTransactionHistory()
        } else {
            errorMessageOutlet.isHidden = false
            errorMessageOutlet.text = "Enter Valid IMEI number."
        }
    }
    
    // MARK: Spread Sheet Delegates
    
    func numberOfColumns(in spreadSheetVw: SpreadsheetView) -> Int {
        return 8
        
    }
    
    func numberOfRows(in spreadSheetVw: SpreadsheetView) -> Int {
        if recordsArray.count != 0 {
            let transactionCount : Int = recordsArray.count
            let nextBtnY = nextButtonOutlet.frame.origin.y
            let spreadSheetY = spreadSheetVw.frame.origin.y
            let maxSpreadSheetWidth  = nextBtnY - spreadSheetY - 20
            if maxSpreadSheetWidth < CGFloat(40 * transactionCount) {
                spreadSheetHeightConstraint.constant = maxSpreadSheetWidth
            }  else {
                spreadSheetHeightConstraint.constant = CGFloat(40 * transactionCount)
            }
        }
        return recordsArray.count
    }
    
    func spreadsheetView(_ spreadSheetVw: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 40
        } else if case 3 = column {
            return 50
        } else if case 6 = column {
            return 130
        } else {
            return 100
        }
    }
    
    func spreadsheetView(_ spreadSheetVw: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 40
    }
    
    func frozenColumns(in spreadSheetVw: SpreadsheetView) -> Int {
        
        return (recordsArray.count > 0) ? 1 : 0
    }
    
    func frozenRows(in spreadSheetVw: SpreadsheetView) -> Int {
        return (recordsArray.count > 0) ? 1 : 0
    }

    func spreadsheetView(_ spreadSheetVw: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {

        var cell:DataCell? = nil

        if(indexPath.column != 6){
            cell = spreadSheetVw.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as? DataCell
            cell?.label.numberOfLines = 0
        }
        let record = recordsArray[indexPath.row]
        
        switch indexPath.column {
        case 0:
            cell?.label.text = "\(indexPath.row)"
            cell?.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
        case 1:
            if indexPath.row == 0 {
            cell?.label.text = "Date"
            cell?.label.textColor = UIColor.white
        } else {
        cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor

            cell?.label.text = dateFromMillisecinds(timeInMilliseconds: record.startDateTime)//record["Date"]
            cell?.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
            }
        case 2:
            cell?.label.text = record.userId
            cell?.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
        case 3:
            cell?.label.text = record.storeid
            cell?.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
        case 4:
            cell?.label.text = record.storeLocation
            cell?.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
        case 5:
            cell?.label.text = record.programUsed
            cell?.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
        case 6:
            let resCell = spreadSheetVw.dequeueReusableCell(withReuseIdentifier: String(describing: ResultCell.self), for: indexPath) as! ResultCell
            resCell.label.numberOfLines = 0
            
            resCell.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
            if indexPath.row == 0 {
                resCell.label.text = record.sessionStatus
                resCell.label.textColor = UIColor.black
                resCell.backgroundColor = topRowColor
                resCell.layer.masksToBounds = true
                return resCell
            }
            resCell.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            if record.sessionStatus.caseInsensitiveCompare("QUALIFIED") == ComparisonResult.orderedSame  {
                resCell.label.text = "Qualified"
                resCell.imageView.image = UIImage.init(named: "qualified")
            } else {
                resCell.label.text = "Not Qualified"
                resCell.imageView.image = UIImage.init(named: "unqualified")
            }
            return resCell
        case 7:
            if indexPath.row == 0 {
                cell?.label.text = "Action"
                cell?.label.textColor = UIColor.white
            } else {
                let underlineAttribute = [kCTUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
                let underlineAttributedString = NSAttributedString(string: "Preview", attributes: underlineAttribute as [NSAttributedStringKey : Any])
                cell?.label.attributedText = underlineAttributedString
                cell?.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            }
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
        default:
            cell?.label.text = "default"
            cell?.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
        }
        
        if indexPath.row == 0 {
            cell?.label.textColor = UIColor.black
            cell?.backgroundColor = topRowColor
            cell?.layer.masksToBounds = true
        }
        
        if ((indexPath.row == 0) && (indexPath.column == 0)) {
            cell?.label.text = "S.No"
        }

        return cell
    }
    
    func spreadsheetView(_ spreadSheetVw: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0 && indexPath.column == 7 {
            let transactionID = "\(recordsArray[indexPath.row].acdcSessionId)"
            self.getPDFPreview(forSelectedTransactionID:transactionID)
        }
    }
    
    
    // MARK: PDF Reader Delegates
    
//    private func document(_ name: String) -> PDFDocument? {
//        guard let documentURL = Bundle.main.url(forResource: name, withExtension: "pdf") else { return nil }
//        return PDFDocument(url: documentURL)
//    }
    
    private func document(_ data: Data) -> PDFDocument? {
        return PDFDocument(fileData: data, fileName: "Sample PDF")
    }
    
    private func showDocument(_ document: PDFDocument, transactionID: String) {
        let image = UIImage(named: "")
        let controller = HistoryPreviewViewController.createNew(with: document, title: "", actionButtonImage: image, actionStyle: .activitySheet)
        controller.dataa = PDFDataForPrint
        controller.previewTrasactionID = transactionID
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .formSheet
        controller.preferredContentSize = CGSize(width: view.frame.size.width*5/6, height: view.frame.size.height*5/6)
        present(controller, animated: true)
    }
}

//API calls
extension IMEIViewController {
    
    func getListOfChambers() {

        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        guard let validIMEInumber = IMEItextField.text else {
            
            DispatchQueue.main.async {
                ACDCUtilities.showMessage(title: "Alert", msg: "Please enter valid IMEI number.")
            }
            return
        }
        

        let inputStoreID = UserDefaults.standard.value(forKey: "STORE_ID") as! String
        let inputTransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.fetchChamberList(forIMEI: validIMEInumber, storeIdentifier: inputStoreID, transactionIdentifier: inputTransactionID, successCallback: {(statusCode, responseResult) in
            
            
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
                //for a success response stor the IMEI
                UserDefaults.standard.set(validIMEInumber, forKey: "IMEI_TRANSACTION")
                UserDefaults.standard.synchronize()
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                print("End result for IMEI init session is \(jsonResponse)")
                
                    //We should get array of dictionaries as a value for "data" key

                    guard let parsedResponse = (jsonResponse as? [String : Any]) else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                        return
                    }
                    
                    guard let dataArray = parsedResponse["data"] as? [[String:Any]] else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Unexpected response received")
                        }
                        return
                    }
                    
                    if(dataArray.count == 0) {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "Alert", msg: "Empty chamber list received.")
                        }
                        return
                    }
                
               else if(dataArray.count == 1) {
                 //if there is only one chamber check the status of the chamber, if "free" then try establishing chmaber connection
                    let chamberDataDict = dataArray[0];
                    
                    
                    //TODO: Chamber free status uncomment in production
                    guard let chamberStatus = chamberDataDict["status"] as? String else {
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Chamber status not received")
                        }
                        
                        return
                    }
                    if(chamberStatus.caseInsensitiveCompare("FREE") == ComparisonResult.orderedSame){
                        var chamberId:String = ""
                        
                        if(chamberDataDict["chamberId"] is String){
                            //what happens if nil?
                            chamberId = chamberDataDict["chamberId"] as! String
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ChamberConnectionCheckVC") as! ChamberConnectionCheckVC
                            vc.chamberIdentifier = chamberId
                            self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                            self.navigationController?.pushViewController(vc, animated: true)

                        }
                        else if(chamberDataDict["chamberId"] is NSNumber){
                            chamberId = (chamberDataDict["chamberId"] as! NSNumber).stringValue

                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ChamberConnectionCheckVC") as! ChamberConnectionCheckVC
                            vc.chamberIdentifier = chamberId
                            self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)

                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    
                    }else {
                        //TODO: Chamber is not FREE. Prompt an alert
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "Alert", msg: "Chamber is not free. Please free the chamber and try again.")
                        }
                    }
                    
                }else if(dataArray.count > 1) {
                 //if there are multiple chambers move to a screen and display chambers and and their status
                    //TODO: Navigate to screen that displays the chamber list
                    DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ChamberSelectionViewController") as! ChamberSelectionViewController
                    vc.receivedChamberInfo = dataArray
                    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
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
    
    func getTransactionHistory() {
        
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        guard let validIMEInumber = IMEItextField.text else {
            
            DispatchQueue.main.async {
                ACDCUtilities.showMessage(title: "Alert", msg: "Please enter valid IMEI number.")
            }
            return
        }
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.fetchIMEIhistory(forIMEIValue: validIMEInumber, successCallback: {(statusCode, responseResult) in
            
            guard let receivedStatusCode = statusCode else {
                //Status code should always exists
                DispatchQueue.main.async {
                    ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                }
                return
            }
            
            if(receivedStatusCode == 200) {
                
                guard let dataResponse = responseResult else {
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                    }
                    return
                }
                
                do{
                //for a success response stor the IMEI
                UserDefaults.standard.set(validIMEInumber, forKey: "IMEI_TRANSACTION")
                UserDefaults.standard.synchronize()

                    //parse dataResponse
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])

                    guard let parsedResponse = (jsonResponse as? [String : Any]) else {
                        
                        DispatchQueue.main.async {
                            ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                        }
                        return
                    }
                    
                guard let receivedData = (parsedResponse["data"]! as? [[String:Any]]) else {
                    
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Unexpected response received")
                    }
                    return
                }
                
                self.recordsArray.removeAll()
                self.loadProductDataFor(flags: receivedData)
                
                    if self.recordsArray.count == 0 {
                        self.errorMessageOutlet.isHidden = false
                        self.errorMessageOutlet.text = "No records found."
                        return
                    }
                    
                    self.spreadSheetVw.isHidden = false

                    let headerHistoryRecord = HistoryRecord.init(json: ["acdcSessionId": "", "sessionStatus": "Results", "sessionStage": "", "userId": "Store Rep ID", "storeRepId": "", "imei": "", "programUsed": "Purpose Of Visit", "chamberRetryAttempts": "", "imagecapturedtime": "", "chamberId": "", "storeid": "Store Id", "admServerUsed": "", "admNetworkVersion": "", "acdcApplicationVersion": "", "acdcFirmvareVersion": "", "overallResult": "", "startDateTime": "Date", "endDateTime": "", "customerRating": "", "operatorRating": "", "evaluationAccepted": "", "deviceExchanged": "", "additionalInfo": "", "storeLocation":"Store Location"])
                    self.recordsArray.insert(headerHistoryRecord, at: 0)

//                    print(self.recordsArray)
                
                    DispatchQueue.main.async {
                        self.spreadSheetVw.reloadData()
                    }
                
                }  catch  {
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
    
    func loadProductDataFor(flags:[[String:Any]]) {
        for count in 0..<flags.count {
            let prodModel = HistoryRecord.init(json: flags[count])
            recordsArray.append(prodModel)
        }
    }

    func getPDFPreview(forSelectedTransactionID: String) {
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
            
        }
        
        PreviewPDFAPI.fetchPDFData(transactionID: forSelectedTransactionID) { (PDFData, errorMessage) -> (Void) in
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
            
            self.PDFDataForPrint = receivedPDFData
            
            DispatchQueue.main.async {
                if let doc = self.document(receivedPDFData) {
                    self.showDocument(doc, transactionID: forSelectedTransactionID)
                } else {
                    print("Document named not found in the file system")
                }
            }
        }
    }
}
