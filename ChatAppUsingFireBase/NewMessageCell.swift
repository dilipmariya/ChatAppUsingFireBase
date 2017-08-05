//
//  NewMessageCell.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 19/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit

class NewMessageCell: UITableViewCell {

    @IBOutlet var lblUserEmail: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblTimeStamp: UILabel!
    @IBOutlet var imgUser: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
