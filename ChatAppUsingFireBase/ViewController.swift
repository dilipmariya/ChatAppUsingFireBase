//
//  ViewController.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 19/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet var btnProfileImage: UIButton!
    @IBOutlet var vwMainView: UIView!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet var scLogin: UISegmentedControl!
    
    @IBOutlet var txtNameAspectRatio: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brown
        vwMainView.layer.cornerRadius = 5.0
        vwMainView.layer.masksToBounds = true
        
        btnRegister.layer.cornerRadius = 5.0
        btnRegister.layer.masksToBounds = true
        btnRegister.tag = 1
        scLogin.selectedSegmentIndex = 1;
        
        self.navigationController?.navigationBar.isHidden = true
        self.perform(#selector(NaviGate), with: nil, afterDelay: 0)
        //self.view.backgroundColor
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func NaviGate()  {
        if FIRAuth.auth()?.currentUser?.uid != nil
        {
            let stroyboardFile = UIStoryboard.init(name: "Main", bundle: nil)
            let Home = stroyboardFile.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(Home, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func TapOnSegement(_ sender: Any) {
        if scLogin.selectedSegmentIndex == 0
        {
            txtNameAspectRatio.constant = 131/0.000001
            btnRegister.tag = 2
            btnRegister.setTitle("Login", for: .normal)
            btnRegister.setTitle("Login", for: .normal)
        }
        else
        {
            txtNameAspectRatio.constant = 0.0
            btnRegister.tag = 1
            btnRegister.setTitle("Register", for: .normal)
            btnRegister.setTitle("Register", for: .normal)
        }
    }

    @IBAction func btnProfile(_ sender: Any) {
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
            btnProfileImage.setImage(PickedImage, for: .normal)
            btnProfileImage.setImage(PickedImage, for: .highlighted)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        
        if (sender as AnyObject).tag == 1
        {
            self.RegisterValue()
        }
        else
        {
            guard  let email = txtEmail.text, let pass = txtPassword.text else {
                return
            }
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                if error != nil
                {
                    print(error!)
                }
                //SignIn Successfully
                let stroyboardFile = UIStoryboard.init(name: "Main", bundle: nil)
                let Home = stroyboardFile.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.navigationController?.pushViewController(Home, animated: false)
            })
        }
    }
    
    func RegisterValue()
    {
        guard let name = txtName.text, let email = txtEmail.text, let pass = txtPassword.text else {
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
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
            let datFile = UIImagePNGRepresentation((self.btnProfileImage.imageView?.image!)!)
            storage.put(datFile!, metadata: nil, completion: { (meta, error) in
                if let url = meta?.downloadURL()?.absoluteString
                {
                    let fireRef = FIRDatabase.database().reference(fromURL: FireBaseUrlRef)
                    let userRef = fireRef.child(UserTable).child(userid)
                    let Value = [UserTable_Name:name,UserTable_Email:email,UserTable_ProfileImageUrl:url];
                    userRef.updateChildValues(Value, withCompletionBlock: { (error, dataRef) in
                        if error != nil
                        {
                            print(error!)
                        }
                        //add data successfully
                    })
                }
            })
        })
    }
    
}

