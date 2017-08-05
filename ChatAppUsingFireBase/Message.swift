//
//  Message.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 21/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    var message:String?
    var senderid:String?
    var recieverid:String?
    var timestamp:String?
    var imageUrl:String?
    var videoUrl:String?
    var imageWidth:NSNumber?
    var imageHeight:NSNumber?
    func chatUserId() -> String? {
        return recieverid == FIRAuth.auth()?.currentUser?.uid ? senderid : recieverid
    }
    
    init(_ dictionary:[String:AnyObject]) {
        message = dictionary[MessageTable_message] as? String
        senderid = dictionary[MessageTable_senderId] as? String
        recieverid = dictionary[MessageTable_recieverId] as? String
        timestamp = dictionary[MessageTable_timeStamp] as? String
        videoUrl = dictionary[MessageTable_videoUrl] as? String
        imageUrl = dictionary[MessageTable_imageUrl] as? String
        imageWidth = dictionary[MessageTable_imageWidth] as? NSNumber
        imageHeight = dictionary[MessageTable_imageHeight] as? NSNumber
    }
}
