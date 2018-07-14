//
//  ModuleSelectionViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 07/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit
import AcdcNetwork

struct ProductModel {
   
    var productName: String = ""
    var productDescription: String = ""
    var productImage: UIImage? = nil
    var productTagName: String = ""
    
    init(productTagName: String){
        
        switch productTagName {
        case "BUYERS_REMORSE":
            self.productName = "BUYERS REMORSE"
            self.productDescription = "Return a new phone if it doesn’t meet your expectations"
            self.productImage = UIImage.init(named: "remorse")!
            self.productTagName = "BUYERS_REMORSE"
        case "WARRANTY_EXCHANGE":
            self.productName = "WARRANTY EXCHANGE"
            self.productDescription = "Return a phone covered under warranty"
            self.productImage = UIImage.init(named: "warranty")!
            self.productTagName = "WARRANTY_EXCHANGE"
        case "TRADE_IN":
            self.productName = "TRADE IN"
            self.productDescription = "Purchase a new phone under the Trade In program"
            self.productImage = UIImage.init(named: "tradein")!
            self.productTagName = "TRADE_IN"
        case "JUMP":
            self.productName = "JUMP"
            self.productDescription =  "Upgrade to a new phone under the JUMP! program"
            self.productImage = UIImage.init(named: "jump")!
            self.productTagName = "JUMP"
        case "JUMP_ON_DEMAND":
            self.productName = "JUMP ON DEMAND"
            self.productDescription = "Upgrade to a new phone under the JUMP! On Demand program"
            self.productImage = UIImage.init(named: "jump-ondemand")!
            self.productTagName = "JUMP_ON_DEMAND"

        default:
            self.productName = ""
            self.productDescription = ""
            self.productImage = nil
            self.productTagName = ""
        }
    }
    
}

class ModuleSelectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,HamburgerMenuProtocol {
    
    @IBOutlet weak var modulesCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    
    var productList: [ProductModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "What brings you in today?"
        modulesCollectionView.delegate = self
        modulesCollectionView.dataSource = self
        
        let multiplier : Float = Float(productList.count)
        if multiplier > 5 {
            collectionViewWidth.constant = CGFloat(190.0 * 5)
        } else {
            collectionViewWidth.constant = CGFloat(190.0 * multiplier)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HamburgerMenuViewController") as! HamburgerMenuViewController
        vc.delegate = self
        vc.tableViewCellData = [["About","Contact"],["Logout"]]
        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.navigationController?.navigationItem.title = "Menu"
        present(navController, animated: true, completion: nil)
    }

    // MARK: Hamburger menu delegate
    func popToSelectedOption(selectedOption: String) {
        if selectedOption == "Logout" {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is LoginViewController {
                    self.navigationController?.popToViewController(aViewController, animated: true)
                }
            }
        }
    }

    //COLLECTION VIEW STUFFS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "collectionViewCell"
        let cell: ModuleSelectCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ModuleSelectCollectionViewCell
        cell?.layer.masksToBounds = true
        
        let moduleRecord = productList[indexPath.row]
        cell?.moduleName.text = moduleRecord.productName
        cell?.moduleDescription.text = moduleRecord.productDescription
        cell?.moduleImage.image = moduleRecord.productImage
        
        return cell!

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let network: NetworkManager = NetworkManager.sharedInstance
        if(network.reachability.connection == .none) {
            ACDCUtilities.showMessage(title: "Alert", msg: "Internet connection appears to be offline.Please connect to a network in order to proceed.")
            return
        }
        let selectedProgram = productList[indexPath.row].productTagName
        self.sendSelectedProductToServer(name: selectedProgram)
    }
    
    

    func loadProductDataFor(flags:[String]) {
        
        for count in 0..<flags.count {
            let prodModel = ProductModel.init(productTagName: flags[count])
            self.productList.append(prodModel)
        }
    }
    
    func sendSelectedProductToServer(name:String) {
        
        let inputStoreID = UserDefaults.standard.value(forKey: "STORE_ID") as! String
        
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.startCosmeticCheck(forProgram: name, storeIdentifier: inputStoreID, successCallback: {(statusCode, responseResult) in
            
            
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
            
            do{
                //parse dataResponse
                //TODO:Are guard statements necessary while in try catch block?
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                
                guard let parsedResponse = (jsonResponse as? [String : Any]) else {
                    
                    DispatchQueue.main.async {
                        ACDCUtilities.showMessage(title: "ERROR", msg: "Something went wrong. Received bad response.")
                    }
                    return
                }
                
                //We get TransactionID as a value for "data" key
                var inputTransactionID:String = ""
                
                if(parsedResponse["data"] is String){
                    //what happens if nil?
                    inputTransactionID = parsedResponse["data"] as! String
                    
                    UserDefaults.standard.set(inputTransactionID, forKey: "TRANSACTION_ID")
                    UserDefaults.standard.synchronize()
                    
                    //Navigate to IMEI screen
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "IMEIViewController") as! IMEIViewController
                    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                else if(parsedResponse["data"] is NSNumber){
                    inputTransactionID = (parsedResponse["data"] as! NSNumber).stringValue
                    
                    UserDefaults.standard.set(inputTransactionID, forKey: "TRANSACTION_ID")
                    UserDefaults.standard.synchronize()
                    
                    //Navigate to IMEI screen
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "IMEIViewController") as! IMEIViewController
                    self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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

}
