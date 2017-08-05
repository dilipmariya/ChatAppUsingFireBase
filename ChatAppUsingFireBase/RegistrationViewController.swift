//
//  RegistrationViewController.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 26/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase
class RegistrationViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet var vwNavigation: UIView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var srcRegistration: UIScrollView!
    @IBOutlet var vwMainView: UIView!
    @IBOutlet var btnProfilePic: UIButton!
    @IBOutlet var txtFirstName: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtLastName: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtPhoneNumber: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtEmail: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtConfirmPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var btnSubmit: UIButton!
    var ProfileImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in self.vwNavigation.subviews
        {
            if item is UILabel || item is UITextField || item is UIButton
            {
                BaseClass.sharedInstance.setFontValue(item)
            }
        }
        
        for item in self.vwMainView.subviews
        {
            if item is UILabel || item is UITextField || item is UIButton
            {
                BaseClass.sharedInstance.setFontValue(item)
            }
        }
        
        txtPhoneNumber.iconImage.image = UIImage.init(named: "IconPhone")?.maskWithColor(color: UIColor.white)
        txtFirstName.iconImage.image = UIImage.init(named: "IconUser")?.maskWithColor(color: UIColor.white)
        txtLastName.iconImage.image = UIImage.init(named: "IconUser")?.maskWithColor(color: UIColor.white)
        txtPassword.iconImage.image = UIImage.init(named: "IconLock")?.maskWithColor(color: UIColor.white)
        txtConfirmPassword.iconImage.image = UIImage.init(named: "IconLock")?.maskWithColor(color: UIColor.white)
        txtEmail.iconImage.image = UIImage.init(named: "IconMail")?.maskWithColor(color: UIColor.white)
        btnBack.superview?.layer.zPosition = CGFloat(INT_MAX)
        
        btnBack.setImage(UIImage.init(named: "IconBack")?.maskWithColor(color: UIColor.white), for: .normal)
        btnBack.setImage(UIImage.init(named: "IconBack")?.maskWithColor(color: UIColor.white), for: .highlighted)
    }
    
    override func viewDidLayoutSubviews() {
        btnProfilePic.layer.cornerRadius = btnProfilePic.frame.size.height/2
        btnProfilePic.clipsToBounds = true
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height/2
        srcRegistration.contentSize = CGSize.init(width: srcRegistration.contentSize.width, height: btnSubmit.frame.origin.y + btnSubmit.frame.size.height + 20)
        btnSubmit.superview?.translatesAutoresizingMaskIntoConstraints = true
        btnSubmit.superview?.frame = CGRect.init(x: (btnSubmit.superview?.frame.origin.x)!, y: (btnSubmit.superview?.frame.origin.y)!, width: self.view.frame.size.width, height: srcRegistration.contentSize.height)
        BaseClass.sharedInstance.setShadowOnView(btnBack.superview!, 2, UIColor.darkGray)
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnProfilePic(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.isEditing = false
        
        let actionSheet =  UIAlertController(title: "Select Profile Photo", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.default){ (libSelected) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        actionSheet.addAction(libButton)
        let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default) { (camSelected) in
            
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
            {
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                actionSheet.dismiss(animated: false, completion: nil)
                let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                    
                    alert.dismiss(animated: true, completion: nil)
                }))
            }
        }
        actionSheet.addAction(cameraButton)
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (cancelSelected) in
            
        }
        actionSheet.addAction(cancelButton)
        let albumButton = UIAlertAction(title: "Saved Album", style: UIAlertActionStyle.default) { (albumSelected) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            self.present(imagePicker, animated: true, completion: nil)
        }
        actionSheet.addAction(albumButton)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
            self.present(actionSheet, animated: true, completion: nil)
        }
        else
        {
            self.present(actionSheet, animated: true, completion:nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let PickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            btnProfilePic.setImage(PickedImage, for: .normal)
            btnProfilePic.setImage(PickedImage, for: .highlighted)
            ProfileImage = PickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        let strFirstName = txtFirstName.text?.TrimString()
        let strLastName = txtLastName.text?.TrimString()
        let strEmail = txtEmail.text?.TrimString()
        let strPhoneNumber = txtPhoneNumber.text?.TrimString()
        let strPassword = txtPassword.text?.TrimString()
        let strConfirmPassword = txtConfirmPassword.text?.TrimString()
        
        if strFirstName == "" || strLastName == "" || strEmail == "" || strPhoneNumber == "" || strPassword == "" || strConfirmPassword == "" || ProfileImage == nil
        {
            //show error message
            if strFirstName == ""
            {
                txtFirstName.shake(count: 4, for: 0.4, withTranslation: 10)
                txtFirstName.lineColor = UIColor.red
            }
            if strLastName == ""
            {
                txtLastName.shake(count: 4, for: 0.4, withTranslation: 10)
                txtLastName.lineColor = UIColor.red
            }
            if strEmail == ""
            {
                txtEmail.shake(count: 4, for: 0.4, withTranslation: 10)
                txtEmail.lineColor = UIColor.red
            }
            if strPhoneNumber == ""
            {
                txtPhoneNumber.shake(count: 4, for: 0.4, withTranslation: 10)
                txtPhoneNumber.lineColor = UIColor.red
            }
            if strPassword == ""
            {
                txtPassword.shake(count: 4, for: 0.4, withTranslation: 10)
                txtPassword.lineColor = UIColor.red
            }
            if strConfirmPassword == ""
            {
                txtConfirmPassword.shake(count: 4, for: 0.4, withTranslation: 10)
                txtConfirmPassword.lineColor = UIColor.red
            }
        }
        else if (strEmail?.isValidEmail())! == false
        {
            //show error message Invalid EmailId
            txtEmail.shake(count: 4, for: 0.4, withTranslation: 10)
            txtEmail.lineColor = UIColor.red
        }
        else if strPassword != strConfirmPassword
        {
            //show error message Invalid EmailId
            txtPassword.shake(count: 4, for: 0.4, withTranslation: 10)
            txtPassword.lineColor = UIColor.red
            txtConfirmPassword.shake(count: 4, for: 0.4, withTranslation: 10)
            txtConfirmPassword.lineColor = UIColor.red
        }
        else
        {
            self.SaveUser()
        }
    }
    
    func SaveUser()
    {
        let strFirstName = txtFirstName.text?.TrimString()
        let strLastName = txtLastName.text?.TrimString()
        let strEmail = txtEmail.text?.TrimString()
        let strPhoneNumber = txtPhoneNumber.text?.TrimString()
        let strPassword = txtPassword.text?.TrimString()
        
        FIRAuth.auth()?.createUser(withEmail: strEmail!, password: strPassword!, completion: { (user, error) in
            if error != nil{
                print(error!)
            }
            
            //Add successfully
            guard let userid = user?.uid else
            {
                return
            }
            
            let uniqueString = UUID().uuidString
            let storage = FIRStorage.storage().reference().child("UserProfile").child("\(uniqueString).png")
            let datFile = UIImageJPEGRepresentation(self.ProfileImage, 0.2)
            storage.put(datFile!, metadata: nil, completion: { (meta, error) in
                if let url = meta?.downloadURL()?.absoluteString
                {
                    let fireRef = FIRDatabase.database().reference(fromURL: FireBaseUrlRef)
                    let userRef = fireRef.child(UserTable).child(userid)
                    let Value = [UserTable_Name:strFirstName! + " " + strLastName!
                        ,UserTable_Email:strEmail
                        ,UserTable_PhoneNumber:strPhoneNumber
                        ,UserTable_ProfileImageUrl:url];
                    userRef.updateChildValues(Value as [String:AnyObject], withCompletionBlock: { (error, dataRef) in
                        if error != nil
                        {
                            print(error!)
                        }
                        else
                        {
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                            self.navigationController?.pushViewController(nextViewController, animated: false)
                        }
                        //add data successfully
                    })
                }
            })
        })
    }
    
}
