//
//  NewMessageViewController.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 19/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class NewMessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var vwNavigationView: UIView!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var tlbList: UITableView!
    
    var userData = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tlbList.tableFooterView = UIView()
        tlbList.delegate = self
        self.getTheAllUser()
        btnCancel.superview?.layer.zPosition = CGFloat(INT_MAX)
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        BaseClass.sharedInstance.setShadowOnView(btnCancel.superview!, 2, UIColor.darkGray)
    }
    
    func getTheAllUser() {
        
        FIRDatabase.database().reference().child(UserTable).observe(.childAdded, with: { (snapshot) in
            if let newDict = snapshot.value as? [String:AnyObject]
            {
                if let uid = FIRAuth.auth()?.currentUser?.uid
                {
                    if uid == snapshot.key
                    {
                        return
                    }
                }
                let user = User()
                user.id = snapshot.key
                user.name = newDict[UserTable_Name] as? String
                user.email = newDict[UserTable_Email] as? String
                user.profileImageUrl = newDict[UserTable_ProfileImageUrl] as? String
                self.userData.append(user)
                DispatchQueue.main.async {
                    self.tlbList.reloadData()
                }
            }
            
        }, withCancel: nil)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.NavigateToHomeView()
    }
    
    // MARK: - TableView datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tlbList.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! NewMessageCell
        let user = userData[indexPath.row]
        cell.lblUserName.text = user.name
        cell.lblUserEmail.text = user.email
        cell.imgUser.sd_setImage(with: URL.init(string: user.profileImageUrl!))
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2
        cell.imgUser.layer.masksToBounds = true
        return cell
    }

    // MARK: - TableView delegate method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stroyboardFile = UIStoryboard.init(name: "Main", bundle: nil)
        let Chat = stroyboardFile.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        Chat.user = userData[indexPath.row]
        self.navigationController?.pushViewController(Chat, animated: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
