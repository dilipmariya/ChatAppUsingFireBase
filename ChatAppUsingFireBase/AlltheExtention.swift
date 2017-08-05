//
//  String+Validation.swift
//  WeatherMonitor
//
//  Created by sanjeet on 11/16/16.
//  Copyright © 2016 sanjeet. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension String {
    
    public func TrimString() -> String {
        
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func localized() ->String {
        let lang = UserDefaults.standard.value(forKey: "currentAppLanguage") as! String
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: self, comment: "")
    }
    
    public func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
    
    public func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: self.TrimString())
        
        return result
    }
    public func phoneNumberValidation(phoneNumber:String) -> Bool {
        
        let charcterSet = NSCharacterSet(charactersIn: "+0123456789").inverted
        
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        
        let filtered = inputString.joined(separator: "")
        
        return phoneNumber == filtered
    }
    public func isPasswordSame(password:String,confirmPassword:String) -> Bool {
        
        if password == confirmPassword{
            
            return true
        }else{
            return false
        }
    }
    
    public func isPwdLenth(password:String,confirmPassword:String) -> Bool {
        
        if password.characters.count <= 7 && confirmPassword.characters.count <= 7{
            
            return true
        }else{
            return false
        }
    }
}
extension NSAttributedString {
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}

extension UIViewController : MBProgressHUDDelegate {

    func hideKeyboardWhenTappedAround(){
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard(){
         view.endEditing(true)
    }
    func showAlertMessage(message:String,title:String) -> Void {
        
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func ShowProgressHUD() {
        DispatchQueue.main.async{
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
        }
    }
    
    func HideProgressHUD() {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view,animated:true)
        }
    }
    
    func NavigateToHomeView() {
        let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let navigation = UINavigationController.init(rootViewController: home)
        self.slideMenuController()?.changeMainViewController(navigation, close: true)
    }
    
    /******************** custom  Pop up method ***********************************/
}
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIColor
{
    convenience init(r:CGFloat,g:CGFloat,b:CGFloat)
    {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}

extension UINavigationController {
    func pop(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool) {
        _ = self.popToRootViewController(animated: animated)
    }
}

extension Date {
    
    static func daysBetweenDates(start: Date,endDate: Date) -> Int{
        let calendar: Calendar = Calendar.current
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: endDate)
        return calendar.dateComponents([.day], from: date1, to: date2).day!
    }
}

extension UIView {
    
    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        layer.removeAllAnimations()
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.repeatCount = count ?? 2
        animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? -5
        layer.add(animation, forKey: "shake")
    }
}



