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

class IMEIViewController: UIViewController, SpreadsheetViewDelegate, SpreadsheetViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var showHistoryOutlet: UIButton!
    @IBOutlet weak var IMEItextField: UITextField!
    @IBOutlet weak var spreadSheetVw: SpreadsheetView!
    
    @IBOutlet weak var errorMessageOutlet: UILabel!
    var json = [String:AnyObject]()
//    var elements : NSMutableArray = NSMutableArray()
    
    
    var recordsArray:[HistoryRecord] = []
    
    let acceptableCharacters = "0123456789."
    let topRowColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
    let evenRowColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    let oddRowColor: UIColor = .white

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IMEItextField.delegate = self
        self.navigationItem.title = "Please enter a device ID"
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        spreadSheetVw.dataSource = self
        spreadSheetVw.delegate = self
        spreadSheetVw.layer.borderColor = UIColor.gray.cgColor
        spreadSheetVw.layer.borderWidth = 1.0
        
        spreadSheetVw.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        spreadSheetVw.intercellSpacing = CGSize(width: 1, height: 1)
        spreadSheetVw.gridStyle = .solid(width: 1.0, color: .gray)
        spreadSheetVw.bounces = false
        spreadSheetVw.register(DataCell.self, forCellWithReuseIdentifier: String(describing: DataCell.self))
        spreadSheetVw.register(ResultCell.self, forCellWithReuseIdentifier: String(describing: ResultCell.self))

        
        IMEItextField.text = "352066060926230"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func showMenu() {
        print("kwenkkw")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Home", style: UIAlertActionStyle.default, handler: { (action) in
            //            ACDCCommonMethods.showMessage(title: "SOME", msg: "SOMMmmmmmm")
            // TODO: Export wordlist
//            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
//            for aViewController in viewControllers {
//                if aViewController is ModuleSelectionViewController {
//                    self.navigationController!.popToViewController(aViewController, animated: true)
//                }
//            }
            print("Home")
            
        }))
        alert.addAction(UIAlertAction(title: "Feedback", style: UIAlertActionStyle.default, handler: { (action) in
            
            // TODO: Import wordlist
            print("Feedback")
            
        }))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) in
//            ACDCCommonMethods.showMessage(title: "Logout", msg: "Are you sure that you want to logout?")
//            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
//            for aViewController in viewControllers {
//                if aViewController is LoginViewController {
//                    self.navigationController!.popToViewController(aViewController, animated: true)
//                }
//            }

            // TODO: Import wordlist
            print("Logout")
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { (action) in
            print("Cancel")
        }))
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
            popoverPresentationController.sourceRect = CGRect(x:self.view.bounds.size.width / 2.0, y:self.view.bounds.size.height / 2.0, width:1.0, height:1.0)
        }
        self.present(alert, animated: true, completion: nil)
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
        for ch : Character in imeiString.characters {
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

    // MARK: Text Field delegates

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.characters.count == 0) {
            return true
        }
        if textField.text?.count == 15 {
//            showHistoryOutlet.isUserInteractionEnabled = true
//            showHistoryOutlet.alpha = 1.0
//            nextButtonOutlet.isUserInteractionEnabled = true
//            nextButtonOutlet.alpha = 1.0
            return false
        }
        if (textField == self.IMEItextField) {
            let cs = NSCharacterSet(charactersIn: self.acceptableCharacters)
            let filtered = string.components(separatedBy: cs as CharacterSet).filter { !$0.isEmpty }
            let str = filtered.joined(separator: "")//filtered.joinWithSeparator("")
            if textField.text?.count == 14 {
                showHistoryOutlet.isUserInteractionEnabled = true
                showHistoryOutlet.alpha = 1.0
                nextButtonOutlet.isUserInteractionEnabled = true
                nextButtonOutlet.alpha = 1.0
            }
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
        self.getListOfChambers()
        
        return
        
        let IMEINum = IMEItextField.text
//        if self.validateIMEI(imeiString: IMEINum!) {
            errorMessageOutlet.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChamberConnectionCheckVC") as! ChamberConnectionCheckVC
            self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)

            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            errorMessageOutlet.isHidden = false
//            errorMessageOutlet.text = "Enter Valid IMEI number."
//        }
    }

    @IBAction func showHistoryPressed(_ sender: Any) {
//        elements.removeAllObjects()
        self.view.endEditing(true)
        
        //TODO:Validate IMEI
        self.getTransactionHistory()
        
        
        
        return
        
        
        
        
        
        
        
        
//        let IMEINum = IMEItextField.text
////        if self.validateIMEI(imeiString: IMEINum!) {
//            errorMessageOutlet.isHidden = true
//
//            let filePath = Bundle.main.path(forResource: "IMEIHistory", ofType: "geojson")
//            let data = NSData(contentsOfFile: filePath ?? "") as Data?
//
//            if let aData = data {
//                json = try! JSONSerialization.jsonObject(with: aData, options: []) as! [String : AnyObject]
//
//                elements.addObjects(from: json["imeidata"] as! [[String:String]])
//                elements.insert([
//                    "serialNumber": "S.No.",
//                    "Date": "Date",
//                    "storeRepId": "Store Rep Id",
//                    "storeId":"Store Id",
//                    "storeLocation":"Store Location",
//                    "purposeOfVisit":"Purpose Of Visit",
//                    "Result":"Results"
//                    ], at: 0)
//            }
        
        
        

//        } else {
//            errorMessageOutlet.isHidden = false
//            errorMessageOutlet.text = "Enter Valid IMEI number."
//        }
    }
    
    // MARK: Spread Sheet Delegates
    
    func numberOfColumns(in spreadSheetVw: SpreadsheetView) -> Int {
        return 8
        
    }
    
    func numberOfRows(in spreadSheetVw: SpreadsheetView) -> Int {
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
            cell?.label.text = record.storeRepId
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
                resCell.label.text = record.overallResult
                resCell.label.textColor = UIColor.black
                resCell.backgroundColor = topRowColor
                resCell.layer.masksToBounds = true
                return resCell
            }
            resCell.label.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
            if record.overallResult == "SUCCESS" {
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
    private func showDocument(_ document: PDFDocument) {
        let image = UIImage(named: "")
        let controller = HistoryPreviewViewController.createNew(with: document, title: "", actionButtonImage: image, actionStyle: .activitySheet)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .formSheet
        controller.preferredContentSize = CGSize(width: view.frame.size.width*5/6, height: view.frame.size.height*5/6)
        present(controller, animated: true)
    }
    

}

//API calls
extension IMEIViewController {
    
    func getListOfChambers() {

        //parameters to send. //TODO:Add guardStatments
        let validIMEInumber = (IMEItextField.text)!
        let inputStoreID = UserDefaults.standard.value(forKey: "STORE_ID") as! String
        let inputtransactionID = UserDefaults.standard.value(forKey: "TRANSACTION_ID") as! String
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.fetchChamberList(forIMEI: validIMEInumber, storeIdentifier: inputStoreID, transactionIdentifier: inputtransactionID) { (responseResult, error) in
            
            guard let dataResponse = responseResult, error == nil else {
                
                //error occured:Prompt alert
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do{
                
                //for a success response stor the IMEI
                UserDefaults.standard.set(validIMEInumber, forKey: "IMEI_TRANSACTION")
                UserDefaults.standard.synchronize()
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as! [String : Any]
                print("End result for IMEI init session is \(jsonResponse)")
                
                //We get array of dictionaries as a value for "data" key
                let dataArray = jsonResponse["data"] as! [[String:Any]]
                
                if(dataArray.count == 1) {
                 //if there is only one chamber check the status of the chamber, if "free" then try establishing chmaber connection
                    let chamberDataDict = dataArray[0];
                    let chamberStatus = chamberDataDict["status"] as! String
//                    if(chamberStatus.caseInsensitiveCompare("FREE") == ComparisonResult.orderedSame){
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
                    
//                    }else {
//                        //TODO: Chamber is not FREE. Prompt an alert
//                    }
                    
                }else if(dataArray.count > 1) {
                 //if there are multiple chambers move to a screen and display chambers and and their status
                    //TODO: Navigate to screen that displays the chamber list
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
            
        }
    }
    
    func getTransactionHistory() {
        
        //parameters to send. //TODO:Add guardStatments
        let validIMEInumber = (IMEItextField.text)!
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.fetchIMEIhistory(forIMEIValue: validIMEInumber) { (responseResult, error) in
            
            guard let dataResponse = responseResult, error == nil else {
                
                //error occured:Prompt alert
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do{
                //for a success response stor the IMEI
                UserDefaults.standard.set(validIMEInumber, forKey: "IMEI_TRANSACTION")
                UserDefaults.standard.synchronize()
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as! [String : Any]
                print("End result for IMEI history session is \(jsonResponse)")

                guard let receivedData = (jsonResponse["data"]! as? [[String:Any]]) else {
                    //TODO: show alert popup
                    return
                }
                
                
                self.recordsArray.removeAll()

                self.loadProductDataFor(flags: receivedData)
                
                let headerHistoryRecord = HistoryRecord.init(json: ["acdcSessionId": "", "sessionStatus": "", "sessionStage": "", "userId": "", "storeRepId": "Store Rep ID", "imei": "", "programUsed": "Purpose Of Visit", "chamberRetryAttempts": "", "imagecapturedtime": "", "chamberId": "", "storeid": "Store Id", "admServerUsed": "", "admNetworkVersion": "", "acdcApplicationVersion": "", "acdcFirmvareVersion": "", "overallResult": "Results", "startDateTime": "Date", "endDateTime": "", "customerRating": "", "operatorRating": "", "evaluationAccepted": "", "deviceExchanged": "", "additionalInfo": "", "storeLocation":"Store Location"])
                self.recordsArray.insert(headerHistoryRecord, at: 0)

                print(self.recordsArray)
                
                DispatchQueue.main.async {
                    self.spreadSheetVw.reloadData()
                }
                
            } catch let parsingError {
                print("Error", parsingError)
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
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        
        acdcRequestAdapter.fetchPreview(forTransactionID: forSelectedTransactionID){ (responseResult, error) in
            
            guard let dataResponse = responseResult, error == nil else {
                
                //error occured:Prompt alert
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do{
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as! [String : Any]
                print("End result for IMEI history session is \(jsonResponse)")
                
                guard let pdfString = jsonResponse["data"] as? String else {
                    //TODO: PDF Data not received! prompt alet
                    return
                }
                
                
                DispatchQueue.main.async {
                        let smallPDFDocumentName = "samplePDF"
                    if let doc = self.document(Data.init(base64Encoded: pdfString)!) {
                        self.showDocument(doc)
                        } else {
                            print("Document named \(smallPDFDocumentName) not found in the file system")
                        }
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
            
        }
    }
}
