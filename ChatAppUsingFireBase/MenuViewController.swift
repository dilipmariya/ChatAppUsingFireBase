//
//  PopUpViewController.swift
//  PopUp
//
//  Created by Andrew Seeley on 6/06/2016.
//  Copyright © 2016 Seemu. All rights reserved.
//

import UIKit
import Firebase
class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var btnCamera: UIButton!
    @IBOutlet var tlbMenu: UITableView!
    @IBOutlet var lblUserName: UILabel!
    var user:User!
    var menuItem = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tlbMenu.separatorStyle = .none
        tlbMenu.tableFooterView = UIView.init(frame: CGRect.zero)
        menuItem.append("Edit Profile")
        menuItem.append("New Message")
        menuItem.append("Change Password")
        menuItem.append("Log Out")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgUser.image = UIImage.init(named: "Profile")
        self.setNavigationTitle()
    }
    
    func setNavigationTitle()  {
        if let uid = FIRAuth.auth()?.currentUser?.uid
        {
            FIRDatabase.database().reference().child(UserTable).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let newDict = snapshot.value as? [String:AnyObject]
                {
                    self.user = User()
                    self.user.id = uid
                    self.user.name = newDict[UserTable_Name] as? String
                    self.user.email = newDict[UserTable_Email] as? String
                    self.user.profileImageUrl = newDict[UserTable_ProfileImageUrl] as? String
                    
                    self.lblUserName.text = newDict[UserTable_Name] as? String
                    self.imgUser.sd_setImage(with: URL.init(string: newDict[UserTable_ProfileImageUrl] as! String))
                    self.imgUser.layer.cornerRadius = self.imgUser.frame.size.height/2
                    self.imgUser.layer.masksToBounds = true
                }
            }, withCancel: nil)
        }
    }
    
    @IBAction func btnCamera(_ sender: Any) {
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
            //imgUser.image = PickedImage
            let ref = FIRStorage.storage().reference(forURL: user.profileImageUrl!)
            ref.delete(completion: { (error) in
                if error != nil
                {
                    
                }
                else
                {
                    print("delete image successfully")
                }
            })
            let uniqueString = UUID().uuidString
            let storage = FIRStorage.storage().reference().child("UserProfile").child("\(uniqueString).png")
            let datFile = UIImageJPEGRepresentation(PickedImage, 0.2)
            storage.put(datFile!, metadata: nil, completion: { (meta, error) in
                guard let userid = FIRAuth.auth()?.currentUser?.uid else
                {
                    return
                }
                if let url = meta?.downloadURL()?.absoluteString
                {
                    let fireRef = FIRDatabase.database().reference(fromURL: FireBaseUrlRef)
                    let userRef = fireRef.child(UserTable).child(userid)
                    userRef.updateChildValues([UserTable_ProfileImageUrl:url], withCompletionBlock: { (error, dataRef) in
                        if error != nil
                        {
                            
                        }
                        else
                        {
                            self.setNavigationTitle()
                            NotificationCenter.default.post(name: NSNotification.Name.init("UpdateNavigationImageAndTitle"), object: nil)
                        }
                    })
                }
                
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        imgUser.layer.cornerRadius = imgUser.frame.size.height/2
        imgUser.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItem.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MenuCell
        cell.lblName.text = menuItem[indexPath.row]
        cell.lblName.font = UIFont.systemFont(ofSize: 17)
        BaseClass.sharedInstance.setFontValue(cell.lblName)
        cell.selectionStyle = .none
        cell.imgIcon.image = UIImage.init(named: "Profile")
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = menuItem[indexPath.row]
        if item == "Log Out"
        {
            do{
                try FIRAuth.auth()?.signOut()
            }
            catch let signoutError
            {
                print(signoutError)
            }
            UserDefaults.standard.set(false, forKey: "UserLogin")
            UserDefaults.standard.set(false, forKey: "RememberMe")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let navigation = UINavigationController.init(rootViewController: nextViewController)
            UIApplication.shared.keyWindow?.rootViewController = navigation
            self.dismiss(animated: false, completion: nil)
        }
        else if item == "Change Password"
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            let navigation = UINavigationController.init(rootViewController: nextViewController)
            self.slideMenuController()?.changeMainViewController(navigation, close: true)
        }
        if item == "New Message"
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NewMessageViewController") as! NewMessageViewController
            let navigation = UINavigationController.init(rootViewController: nextViewController)
            self.slideMenuController()?.changeMainViewController(navigation, close: true)
        }
        if indexPath.row == 1
        {
            
        }
        if indexPath.row == 0
        {
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TimeTableViewController") as! TimeTableViewController
//            let navigation = UINavigationController.init(rootViewController: nextViewController)
            
            //self.slideMenuController()?.changeMainViewController(navigation, close: true)
        }
        if indexPath.row == 5
        {
            //logout
            
            
        }
    }
}
