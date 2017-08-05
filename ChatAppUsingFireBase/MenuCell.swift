//
//  MenuCell.swift
//  ToPointDriver
//
//  Created by Acquaint Mac on 28/06/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var iconLeading: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
