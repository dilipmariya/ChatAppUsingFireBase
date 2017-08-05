//
//  BaseClass.swift
//  WeatherMonitor
//
//  Created by sanjeet on 11/16/16.
//  Copyright © 2016 sanjeet. All rights reserved.
//

import UIKit

class BaseClass: NSObject {
    public class var sharedInstance: BaseClass {
        struct Singleton {
            static let instance = BaseClass()
        }
        return Singleton.instance
    }
    
    func isLandscape() -> Bool
    {
        var check:Bool = false
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight
        {
            check = true
        }
        else
        {
            check = false
        }
        return check
    }
    
    func getPinkColor() -> UIColor
    {
        return UIColor.init(red: 249/255.0, green: 0/255.0, blue: 73/255.0, alpha: 1.0)
    }
    
    func getWorkColor() -> UIColor
    {
        return UIColor.init(red: 0/255.0, green: 149/255.0, blue: 164/255.0, alpha: 1.0)
    }
    
    func getWeekDayColor() -> UIColor
    {
        return UIColor.init(red: 121/255.0, green: 211/255.0, blue: 231/255.0, alpha: 1.0)
    }
    
    func getNavigationShadowColor() -> UIColor
    {
        return UIColor.init(red: 121/255.0, green: 211/255.0, blue: 231/255.0, alpha: 1.0)
    }
    
    func setFontValue(_ sender:AnyObject) {
        if sender is UILabel
        {
            let newLabel = sender as! UILabel
            let newSize:CGFloat = newLabel.font.pointSize * (UIScreen.main.bounds.size.width/320)
            newLabel.font = UIFont.systemFont(ofSize: newSize)
        }
        else if sender is UITextField
        {
            let newLabel = sender as! UITextField
            let newSize:CGFloat = newLabel.font!.pointSize * (UIScreen.main.bounds.size.width/320)
            newLabel.font = UIFont.systemFont(ofSize: newSize)
        }
        else if sender is UIButton
        {
            let newLabel = sender as! UIButton
            let newSize:CGFloat = (newLabel.titleLabel?.font.pointSize)! * (UIScreen.main.bounds.size.width/320)
            newLabel.titleLabel?.font = UIFont.systemFont(ofSize: newSize)
        }
    }
    
    func flipImageVertically(originalImage:UIImage) -> UIImage {
        let image:UIImage = UIImage.init(cgImage: originalImage.cgImage!, scale: 1.0, orientation: UIImageOrientation.down)
        return image
    }
    
    func setShadowOnView(_ view:UIView,_ shadowSize:CGFloat,_ shadowColor:UIColor)  {
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: shadowSize,
                                                   width: view.frame.size.width + shadowSize,
                                                   height: view.frame.size.height + shadowSize))
        view.layer.masksToBounds = false
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowPath = shadowPath.cgPath
    }
    
    func setShadowOnButton(_ view:UIButton,_ shadowSize:CGFloat)
    {
        let shadowColor = UIColor.init(red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1.0)
        let shadowCorner = UIBezierPath.init(roundedRect: CGRect(x: -shadowSize / 2,
                                                                 y: 0,
                                                                 width: view.frame.size.width + shadowSize,
                                                                 height: view.frame.size.height + shadowSize), cornerRadius: view.layer.cornerRadius)
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowPath = shadowCorner.cgPath
    }
}
