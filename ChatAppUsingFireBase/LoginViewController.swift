//
//  LoginViewController.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 26/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var txtEmailId: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var btnRemindme: UIButton!
    @IBOutlet var lblRemindme: UILabel!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnCreateAccount: UIButton!
    var remindme = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for item in self.view.subviews
        {
            if item is UILabel || item is UITextField || item is UIButton
            {
                BaseClass.sharedInstance.setFontValue(item)
            }
        }
        txtPassword.iconImage.image = UIImage.init(named: "IconLock")?.withRenderingMode(.alwaysTemplate)
        txtEmailId.iconImage.image = UIImage.init(named: "IconMail")?.withRenderingMode(.alwaysTemplate)
        
        btnRemindme.setImage(UIImage.init(named: "checkbox_off")?.maskWithColor(color: UIColor.white), for: .normal)
        btnRemindme.setImage(UIImage.init(named: "checkbox_off")?.maskWithColor(color: UIColor.white), for: .highlighted)
        txtPassword.tintColor = UIColor.white
        txtEmailId.tintColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        btnLogin.layer.cornerRadius = btnLogin.frame.size.height/2
        BaseClass.sharedInstance.setShadowOnButton(btnLogin, 3)
    }
    
    //MARK:- All button Action
    
    @IBAction func btnRemindme(_ sender: UIButton) {
        if remindme == false
        {
            remindme = true
            btnRemindme.setImage(UIImage.init(named: "checkbox_on")?.maskWithColor(color: UIColor.white), for: .normal)
            btnRemindme.setImage(UIImage.init(named: "checkbox_on")?.maskWithColor(color: UIColor.white), for: .highlighted)
        }
        else
        {
            remindme = false
            btnRemindme.setImage(UIImage.init(named: "checkbox_off")?.maskWithColor(color: UIColor.white), for: .normal)
            btnRemindme.setImage(UIImage.init(named: "checkbox_off")?.maskWithColor(color: UIColor.white), for: .highlighted)
        }
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        let strEmail = txtEmailId.text?.TrimString()
        let strPassword = txtPassword.text?.TrimString()
        if strEmail == "" || strPassword == ""
        {
            if strEmail == ""
            {
                txtEmailId.shake(count: 4, for: 0.4, withTranslation: 10)
                txtEmailId.lineColor = UIColor.red
            }
            if strPassword == ""
            {
                txtPassword.shake(count: 4, for: 0.4, withTranslation: 10)
                txtPassword.lineColor = UIColor.red
            }
        }
        else if (strEmail?.isValidEmail())! == false
        {
            txtEmailId.shake(count: 4, for: 0.4, withTranslation: 10)
            txtEmailId.lineColor = UIColor.red
        }
        else
        {
            guard  let email = txtEmailId.text, let pass = txtPassword.text else {
                return
            }
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                if error != nil
                {
                    print(error!)
                    return
                }
                //SignIn Successfully
                UserDefaults.standard.set(self.remindme, forKey: "RememberMe")
                let home = self.storyboard?.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
                self.present(home, animated: false, completion: nil)
            })
        }
    }
    
    @IBAction func btnCreateAccount(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

}
