//
//  DetailsViewCell.swift
//  TouchIDIntegration
//
//  Created by Shatadru Datta on 4/13/18.
//  Copyright © 2018 Shatadru. All rights reserved.
//

import UIKit

class DetailsViewCell: BaseTableViewCell {

    @IBOutlet weak var lblContext: UILabel!
    @IBOutlet weak var lblContextValue: UILabel!
    override var datasource: AnyObject? {
        didSet {
            if datasource != nil {
                
            }
        }
    }

}
