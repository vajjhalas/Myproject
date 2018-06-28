//
//  HistoryPreviewViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 21/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.white
        collectionView.register(PDFPageCollectionViewCell.self, forCellWithReuseIdentifier: "page")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendSMS(_ sender: Any) {
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
    
    @IBAction func sendEmail(_ sender: Any) {
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
    
    @IBAction func printPDF(_ sender: Any) {
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

