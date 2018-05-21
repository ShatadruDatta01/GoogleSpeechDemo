//
//  ProfileCell.swift
//  TouchIDIntegration
//
//  Created by Shatadru Datta on 4/13/18.
//  Copyright © 2018 Shatadru. All rights reserved.
//

import UIKit

class ProfileCell: BaseTableViewCell {

    @IBOutlet weak var imgProf: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhno: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    override var datasource: AnyObject? {
        didSet {
            if datasource != nil {
                
            }
        }
    }

}
