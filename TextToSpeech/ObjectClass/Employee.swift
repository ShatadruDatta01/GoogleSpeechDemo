//
//  Employee.swift
//  TouchIDIntegration
//
//  Created by Administrator on 13/04/18.
//  Copyright © 2018 Shatadru. All rights reserved.
//

import UIKit

class Employee: NSObject {

    var emailId: String?
    var displayName: String?
    var firstName: String?
    var KAUSTID: String?
    var lastName: String?
    var housePhone: String?
    var mobileNo: String?
    var userId: String?
    var department: String?
    var position: String?
    var identity: String?
    var officePhone: String?
    init(withDictionary dict:[String: AnyObject]) {
        
        if let emailId = dict["EmailId"] {
            self.emailId = emailId as? String
        }
        
        if let displayName = dict["DisplayName"] {
            self.displayName = displayName as? String
        }
        
        if let firstName = dict["FirstName"] {
            self.firstName = firstName as? String
        }
        
        if let KAUSTID = dict["KAUSTID"] {
            self.KAUSTID = KAUSTID as? String
        }
        
        if let lastName = dict["LastName"] {
            self.lastName = lastName as? String
        }
        
        if let housePhone = dict["HousePhone"] {
            self.housePhone = housePhone as? String
        }
        
        if let mobilePhone = dict["MobileNo"] {
            self.mobileNo = mobilePhone as? String
        }
        
        if let userId = dict["UserId"] {
            self.userId = userId as? String
        }
        
        if let department = dict["Department"] {
            self.department = department as? String
        }
        
        if let position = dict["Position"] {
            self.position = position as? String
        }
        
        if let identity = dict["Identity"] {
            self.identity = identity as? String
        }
        
        if let officePhone = dict["OfficePhone"] {
            self.officePhone = officePhone as? String
        }
    }
}
