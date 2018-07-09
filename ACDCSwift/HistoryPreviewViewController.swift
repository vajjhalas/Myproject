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
        let vc = storyboard.instantiateViewController(withIdentifier: "SMSPrintViewController") as! SMSPrintViewController
        let navController = UINavigationController(rootViewController: vc)
        vc.previewTrasactionID = previewTrasactionID
        vc.selectedOption = "SMS"
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.preferredContentSize = CGSize(width: self.view.frame.width/2, height: self.view.frame.height/2)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SMSPrintViewController") as! SMSPrintViewController
        let navController = UINavigationController(rootViewController: vc)
        vc.previewTrasactionID = previewTrasactionID
        vc.selectedOption = "Email"
        navController.modalTransitionStyle = .coverVertical
        navController.modalPresentationStyle = .formSheet
        navController.preferredContentSize = CGSize(width: self.view.frame.width/2, height: self.view.frame.height/2)
        present(navController, animated: true, completion: nil)
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
