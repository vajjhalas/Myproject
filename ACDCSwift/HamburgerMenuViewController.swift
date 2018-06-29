//
//  HamburgerMenuViewController.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 29/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import UIKit

@objc protocol HamburgerMenuProtocol: class {
    func popToSelectedOption(selectedOption : NSString)
}

class HamburgerMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    weak var delegate : HamburgerMenuProtocol!

    @IBOutlet weak var tableView: UITableView!
    var tableViewCellData = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Menu"
        let rightBarBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneMethod))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        tableView.separatorInset = .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func doneMethod() {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCellData[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewCellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleTableIdentifier = "TableViewCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: simpleTableIdentifier)
        }
        cell?.textLabel?.text = tableViewCellData[indexPath.section][indexPath.row] as? String
        cell?.textLabel?.textAlignment = .left
        
        if tableViewCellData[indexPath.section][indexPath.row] == "Home" || tableViewCellData[indexPath.section][indexPath.row] == "Logout" {
            cell?.accessoryType = .none
        }
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
        proceed(selectedoption: tableViewCellData[indexPath.section][indexPath.row])
    }
    
    func proceed(selectedoption:String) {
        print(selectedoption)
        switch selectedoption {
        case "Logout":
            print("LOGOUT")
        case "Home":
            print("HOME")
        case "Contact","Feedback","About":
            print(selectedoption)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AppDescriptionViewController") as! AppDescriptionViewController
            vc.selectedOption = selectedoption
            self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            print("Do Nothing")
        }
    }
}
