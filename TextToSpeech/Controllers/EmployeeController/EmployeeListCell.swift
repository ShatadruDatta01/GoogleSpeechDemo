//
//  EmployeeListCell.swift
//  TouchIDIntegration
//
//  Created by Administrator on 13/04/18.
//  Copyright © 2018 Shatadru. All rights reserved.
//

import UIKit

class EmployeeListCell: BaseTableViewCell {

    @IBOutlet weak var lblEmployee: UILabel!
    override var datasource: AnyObject? {
        didSet {
            if datasource != nil {
                let val = datasource as! Employee
                self.lblEmployee.text = val.displayName!
            }
        }
    }
}
