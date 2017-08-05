//
//  ChatViewCell.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 21/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit

class ChatViewCell: UICollectionViewCell {
    
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var bubbleWidth: NSLayoutConstraint!
    @IBOutlet var bubbleTrailing: NSLayoutConstraint!
    @IBOutlet var vwBubbleView: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var imgMessage: UIImageView!
    @IBOutlet var vwVideoPlayer: UIView!
    @IBOutlet var imgPlay: UIImageView!
    @IBOutlet var vwIndicatorView: UIActivityIndicatorView!
}
