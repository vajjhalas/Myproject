//
//  AppDescriptionViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 29/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit

class AppDescriptionViewController: UIViewController,UITextViewDelegate {

    var selectedOption : String = ""

    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    
    @IBOutlet weak var sendOutlet: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!
    @IBOutlet weak var feedbackTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneMethod))
        self.navigationItem.rightBarButtonItem = rightBarBtn

        switch selectedOption {
        case "About":
            self.navigationItem.title = "About"
            aboutView.isHidden = false
        case "Contact":
            self.navigationItem.title = "Contact"
            contactView.isHidden = false
        case "Feedback":
            feedbackView.isHidden = false
            feedbackTextField.delegate = self
            feedbackTextField.textColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            feedbackTextField.layer.cornerRadius = 8.0
            feedbackTextField.layer.borderWidth = 1.0
            feedbackTextField.layer.borderColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
            feedbackTextField.text = "Please include a detailed description of the problem of your suggestion."
            sendOutlet.alpha = 0.5
            sendOutlet.isUserInteractionEnabled = false
            self.navigationItem.title = "Feedback"
        default:
            print("fusdvu")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func doneMethod() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        let alert = UIAlertController(title: "Thank you", message: "We have noted your concern. All necessary actions will be taken.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }
    
    //Text Field delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Please include a detailed description of the problem of your suggestion.") {
            feedbackTextField.textColor = UIColor.black
            feedbackTextField.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 1 {
            sendOutlet.alpha = 1.0
            sendOutlet.isUserInteractionEnabled = true
        } else if textView.text.count == 0 {
            sendOutlet.alpha = 0.5
            sendOutlet.isUserInteractionEnabled = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
    }
}
