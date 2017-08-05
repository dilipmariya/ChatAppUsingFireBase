//
//  HomeViewController.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 19/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var NavigationView: UIView!
    @IBOutlet var btnLogout: UIButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var tlbList: UITableView!
    @IBOutlet var imgUserImage: UIImageView!
    var messageData = [Message]()
    var messageDa = [String:Message]()
    
    var timer:Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        tlbList.tableFooterView = UIView()
        tlbList.delegate = self
        lblTitle.text = ""
        
        self.navigationController?.navigationBar.isHidden = true
        btnLogout.superview?.layer.zPosition = CGFloat(INT_MAX)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(setNavigationTitle), name: NSNotification.Name.init("UpdateNavigationImageAndTitle"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        BaseClass.sharedInstance.setShadowOnView(btnLogout.superview!, 2, UIColor.darkGray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationTitle()
        self.getAllmessages()
    }
    
    func setNavigationTitle()  {
        if let uid = FIRAuth.auth()?.currentUser?.uid
        {
            FIRDatabase.database().reference().child(UserTable).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let newDict = snapshot.value as? [String:AnyObject]
                {
                    self.lblTitle.text = newDict[UserTable_Name] as? String
                    self.imgUserImage.sd_setImage(with: URL.init(string: newDict[UserTable_ProfileImageUrl] as! String))
                    self.imgUserImage.layer.cornerRadius = self.imgUserImage.frame.size.height/2
                    self.imgUserImage.layer.masksToBounds = true
                }
            }, withCancel: nil)
        }
    }
    
    func getAllmessages()  {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child(UserMessageTable).child(uid).observe(.childAdded, with: { (snapshot) in
            let userid = snapshot.key
            let newRef = FIRDatabase.database().reference().child(UserMessageTable).child(uid).child(userid)
            newRef.observe(.childAdded, with: { (snapshot) in
                FIRDatabase.database().reference().child(MessageTable).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let newDict = snapshot.value as? [String:AnyObject]
                    {
                        let msg = Message(newDict)
                        if let reId = msg.chatUserId()
                        {
                            self.messageDa[reId] = msg
                        }
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.LoadListView), userInfo: nil, repeats: false)
                    }
                }, withCancel: nil)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func LoadListView() {
        self.messageData = Array(self.messageDa.values)
        self.messageData.sort(by: { (m1, m2) -> Bool in
            return Int(m1.timestamp!)! > Int(m2.timestamp!)!
        })
        DispatchQueue.main.async {
            self.tlbList.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLogOut(_ sender: Any) {
        UIApplication.shared.statusBarStyle = .lightContent
        self.slideMenuController()?.openLeft()
    }
    
    func CallChatViewController(_ user:User) {
        let stroyboardFile = UIStoryboard.init(name: "Main", bundle: nil)
        let Chat = stroyboardFile.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        Chat.user = user
        self.navigationController?.pushViewController(Chat, animated: false)
    }

    @IBAction func btnEdit(_ sender: Any) {
        let stroyboardFile = UIStoryboard.init(name: "Main", bundle: nil)
        let NewMessage = stroyboardFile.instantiateViewController(withIdentifier: "NewMessageViewController") as! NewMessageViewController
        self.navigationController?.pushViewController(NewMessage, animated: false)
    }
    
    // MARK: - TableView datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tlbList.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! NewMessageCell
        let message = messageData[indexPath.row]
        if let rid = message.chatUserId()
        {
            FIRDatabase.database().reference().child(UserTable).child(rid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String:AnyObject]
                {
                    cell.lblUserName.text = dict[UserTable_Name] as? String
                    
                    if let text = message.message
                    {
                        cell.lblUserEmail.text = text
                    }
                    if let imageUrl = message.imageUrl
                    {
                        cell.lblUserEmail.text = "Send a Image"
                    }
                    cell.imgUser.sd_setImage(with: URL.init(string: dict[UserTable_ProfileImageUrl] as! String))
                    cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2
                    cell.imgUser.layer.masksToBounds = true
                    
                    let newDate = NSDate(timeIntervalSince1970: Double(message.timestamp!)!)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:MM:ss a"
                    cell.lblTimeStamp.text = dateFormatter.string(from: newDate as Date)
                }
            }, withCancel: nil)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messageData[indexPath.row]
        if let rid = message.chatUserId()
        {
            FIRDatabase.database().reference().child(UserTable).child(rid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String:AnyObject]
                {
                    let user = User()
                    user.email = dict[UserTable_Email] as? String
                    user.name = dict[UserTable_Name] as? String
                    user.profileImageUrl = dict[UserTable_ProfileImageUrl] as? String
                    user.id = message.chatUserId()
                    
                    let stroyboardFile = UIStoryboard.init(name: "Main", bundle: nil)
                    let Chat = stroyboardFile.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    Chat.user = user
                    self.navigationController?.pushViewController(Chat, animated: false)
                }
            }, withCancel: nil)
        }

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
