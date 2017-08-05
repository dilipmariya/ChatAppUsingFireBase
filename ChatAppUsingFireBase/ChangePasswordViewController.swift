//
//  ChangePasswordViewController.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 28/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
class ChangePasswordViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var txtEmail: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtOldPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtNewPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtConfirmPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var srcChangePassword: UIScrollView!
    @IBOutlet var vwMainView: UIView!
    @IBOutlet var btnSubmit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BaseClass.sharedInstance.setFontValue(lblTitle)
        for item in self.vwMainView.subviews
        {
            if item is UILabel || item is UITextField || item is UIButton
            {
                BaseClass.sharedInstance.setFontValue(item)
            }
        }
        btnBack.superview?.layer.zPosition = CGFloat(INT_MAX)
        txtOldPassword.iconImage.image = UIImage.init(named: "IconLock")?.maskWithColor(color: UIColor.white)
        txtNewPassword.iconImage.image = UIImage.init(named: "IconLock")?.maskWithColor(color: UIColor.white)
        txtConfirmPassword.iconImage.image = UIImage.init(named: "IconLock")?.maskWithColor(color: UIColor.white)
        txtEmail.iconImage.image = UIImage.init(named: "IconMail")?.maskWithColor(color: UIColor.white)
        
        txtOldPassword.delegate = self
        txtNewPassword.delegate = self
        txtConfirmPassword.delegate = self
        txtEmail.delegate = self
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtOldPassword.lineColor = .darkGray
        txtNewPassword.lineColor = .darkGray
        txtConfirmPassword.lineColor = .darkGray
        txtEmail.lineColor = .darkGray
    }
    
    override func viewDidLayoutSubviews() {
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height/2
        srcChangePassword.contentSize = CGSize.init(width: srcChangePassword.contentSize.width, height: btnSubmit.frame.origin.y + btnSubmit.frame.size.height + 20)
        btnSubmit.superview?.translatesAutoresizingMaskIntoConstraints = true
        btnSubmit.superview?.frame = CGRect.init(x: (btnSubmit.superview?.frame.origin.x)!, y: (btnSubmit.superview?.frame.origin.y)!, width: self.view.frame.size.width, height: srcChangePassword.contentSize.height)
        BaseClass.sharedInstance.setShadowOnView(btnBack.superview!, 2, UIColor.darkGray)
    }
    
    @IBAction func btnChangePassword(_ sender: UIButton) {
        
        let strNewPassword = txtNewPassword.text?.TrimString()
        let strOldPassword = txtOldPassword.text?.TrimString()
        let strEmail = txtEmail.text?.TrimString()
        let strConfirmPassword = txtConfirmPassword.text?.TrimString()
        if strNewPassword == "" || strOldPassword == "" || strEmail == "" || strConfirmPassword == ""
        {
            //show error message
            if strNewPassword == ""
            {
                txtNewPassword.shake(count: 4, for: 0.4, withTranslation: 10)
                txtNewPassword.lineColor = UIColor.red
            }
            if strOldPassword == ""
            {
                txtOldPassword.shake(count: 4, for: 0.4, withTranslation: 10)
                txtOldPassword.lineColor = UIColor.red
            }
            if strEmail == ""
            {
                txtEmail.shake(count: 4, for: 0.4, withTranslation: 10)
                txtEmail.lineColor = UIColor.red
            }
            if strConfirmPassword == ""
            {
                txtConfirmPassword.shake(count: 4, for: 0.4, withTranslation: 10)
                txtConfirmPassword.lineColor = UIColor.red
            }
        }
        else if (strEmail?.isValidEmail())! == false
        {
            txtEmail.shake(count: 4, for: 0.4, withTranslation: 10)
            txtEmail.lineColor = UIColor.red
        }
        else if strNewPassword != strConfirmPassword
        {
            //show error message Invalid EmailId
            txtNewPassword.shake(count: 4, for: 0.4, withTranslation: 10)
            txtNewPassword.lineColor = UIColor.red
            txtConfirmPassword.shake(count: 4, for: 0.4, withTranslation: 10)
            txtConfirmPassword.lineColor = UIColor.red
        }
        else
        {
            self.ChangePasswod()
        }
    }
    
    func ChangePasswod()  {
        let strNewPassword = txtNewPassword.text?.TrimString()
        let strOldPassword = txtOldPassword.text?.TrimString()
        let strEmail = txtEmail.text?.TrimString()
        let user = FIRAuth.auth()?.currentUser
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: strEmail!, password: strOldPassword!)
        user?.reauthenticate(with: credential, completion: { (error) in
            if error != nil
            {
                //old email or password must be wrong
            }
            else
            {
                user?.updatePassword(strNewPassword!, completion: { (error) in
                    if error != nil
                    {
                        
                    }
                    else
                    {
                        self.NavigateToHomeView()
                    }
                })
            }
        })
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.NavigateToHomeView()
    }
}
