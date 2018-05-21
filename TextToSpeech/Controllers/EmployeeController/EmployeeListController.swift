//
//  EmployeeListController.swift
//  TouchIDIntegration
//
//  Created by Administrator on 13/04/18.
//  Copyright © 2018 Shatadru. All rights reserved.
//

import UIKit
import SwiftyJSON

class EmployeeListController: BaseViewController {

    var jsonEmployeeList = ""
    var arrDialogFlowData = [AnyObject]()
    var arrEmployee = ["Shatadru Datta", "Syed Rehmat Ali", "Pinaki", "Debajyoti"]
    @IBOutlet weak var tblEmployeeList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(jsonEmployeeList)
        
        self.tblEmployeeList.tableFooterView = UIView()
        
        let swiftyJsonVar   = JSON.parse(jsonEmployeeList);
        print(swiftyJsonVar.count)
        
        for value in swiftyJsonVar.arrayObject! {
            let objEmpList = Employee(withDictionary: value as! [String : AnyObject])
            self.arrDialogFlowData.append(objEmpList)
        }
        
        /*var dictonary:NSDictionary?
        
        if let data = jsonEmployeeList.data(using: String.Encoding.utf8) {
            
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as! NSDictionary
                
                if let myDictionary = dictonary
                {
                    let swiftyJsonVar   = JSON(myDictionary)
                    print(swiftyJsonVar)
                    //print(swiftyJsonVar["fulfillment"]["messages"][0]["dataPayload"].arrayObject!)
                    for value in swiftyJsonVar["fulfillment"]["messages"][0]["dataPayload"].arrayObject! {
                        let objEmpList = Employee(withDictionary: value as! [String : AnyObject])
                        self.arrDialogFlowData.append(objEmpList)
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }*/
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//TableViewDelegate, TableViewDatasource
extension EmployeeListController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDialogFlowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let employeeCell = tableView.dequeueReusableCell(withIdentifier: "EmployeeListCell", for: indexPath) as! EmployeeListCell
        employeeCell.datasource = self.arrDialogFlowData[indexPath.row]
        employeeCell.selectionStyle = .none
        return employeeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsEmployeeController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
        let val = self.arrDialogFlowData[indexPath.row] as! Employee
        detailsEmployeeController?.arrContextValue.append(val.userId!)
        detailsEmployeeController?.arrContextValue.append(val.displayName!)
        detailsEmployeeController?.arrContextValue.append(val.identity!)
        detailsEmployeeController?.arrContextValue.append(val.department!)
        detailsEmployeeController?.arrContextValue.append(val.position!)
        detailsEmployeeController?.arrContextValue.append(val.KAUSTID!)
        detailsEmployeeController?.phno = val.mobileNo!
        detailsEmployeeController?.name = val.displayName!
        detailsEmployeeController?.emailId = val.emailId!
        self.navigationController?.pushViewController(detailsEmployeeController!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
