//
//  SendResultsViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 19/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit

@objc protocol SendResultsProtocol: class {
    func selectedService(selectedString : NSString)
}

class SendResultsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    weak var delegate : SendResultsProtocol!

    @IBOutlet weak var tableVw: UITableView!
    var tableViewCellData = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableViewCellData.append("SMS")
        tableViewCellData.append("Email")
        tableViewCellData.append("Print")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleTableIdentifier = "SimpleTableItem"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: simpleTableIdentifier)
        }
        cell?.textLabel?.text = tableViewCellData[indexPath.row] as? String
        cell?.textLabel?.textAlignment = .center
        if let aSize = UIFont(name: "Arial", size: 18.0) {
            cell?.textLabel?.font = aSize
        }
        if let aCell = cell {
            return aCell
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var someString : NSString = ""
        if indexPath.row == 0 {
            someString = "SMS"
        } else if indexPath.row == 1 {
            someString = "Email"
        } else if indexPath.row == 2 {
            someString = "Print"
        }
        if ((self.delegate) != nil) {
            self.delegate.selectedService(selectedString: someString)
        }
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
