//
//  ChatViewController.swift
//  ChatAppUsingFireBase
//
//  Created by Acquaint Mac on 20/07/17.
//  Copyright © 2017 Acquaint Mac. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
class ChatViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet var srcChatView: UIScrollView!
    var user:User!
    @IBOutlet var vwNavigationView: UIView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lblNavigationTitle: UILabel!
    @IBOutlet var vwSendMessage: UIView!
    @IBOutlet var txtMessage: UITextField!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var clMessage: UICollectionView!
    var messageData = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNavigationTitle.text = user.name
        self.ShowMessage()
        
        btnBack.superview?.layer.zPosition = CGFloat(INT_MAX)
        
    }
    
    override func viewDidLayoutSubviews() {
        BaseClass.sharedInstance.setShadowOnView(btnBack.superview!, 2, UIColor.darkGray)
//        srcChatView.contentSize = CGSize.init(width: srcChatView.contentSize.width, height: self.view.frame.size.height-64)
//        btnSend.superview?.translatesAutoresizingMaskIntoConstraints = true
//        btnSend.superview?.frame = CGRect.init(x: 0, y: -20, width: self.view.frame.size.width, height: srcChatView.contentSize.height)
    }
    
    func ShowMessage() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid,let senderId = user.id else {
            return
        }
        
        FIRDatabase.database().reference().child(UserMessageTable).child(uid).child(senderId).observe(.childAdded, with: { (snapshot) in
            FIRDatabase.database().reference().child(MessageTable).child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictValue = snapshot.value as? [String:AnyObject]
                {
                    let msg = Message(dictValue)
                    self.messageData.append(msg)
                    DispatchQueue.main.async {
                        self.clMessage.reloadData()
                        let indexpath = IndexPath.init(item: self.messageData.count-1, section: 0)
                        self.clMessage.scrollToItem(at: indexpath, at: .bottom, animated: true)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    @IBAction func btnSend(_ sender: Any) {
        self.SendMessage()
    }
    
    func SendMessage()
    {
        let Value = [MessageTable_message:txtMessage.text!] as [String : AnyObject]
        self.SaveTheMessageData(Value)
    }
    
    @IBAction func btnBacke(_ sender: Any) {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                // some process
                if viewController is HomeViewController
                {
                    _ = self.navigationController?.popToViewController(viewController, animated: true)
                }
            } 
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(self.view.frame)
    }
    
    //MARK:- collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = clMessage.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatViewCell
        cell.vwBubbleView.layer.cornerRadius = 16.0
        cell.vwBubbleView.layer.masksToBounds = true
        let msg = messageData[indexPath.item]
        cell.imgUser.isHidden = true
        cell.imgMessage.isHidden = true
        cell.bubbleTrailing.constant = 10
        cell.vwBubbleView.backgroundColor = UIColor.brown
        cell.textView.textColor = UIColor.white
        cell.vwVideoPlayer.isHidden = true
        cell.imgMessage.tag = indexPath.row
        cell.vwBubbleView.tag = indexPath.row
        cell.vwIndicatorView.startAnimating()
        cell.vwIndicatorView.isHidden = true
        cell.imgPlay.isHidden = true
        if let text = messageData[indexPath.item].message
        {
            cell.textView.text = text
            cell.bubbleWidth.constant = self.getSizeOfCell(msg.message!).width + 28
        }
        else
        {
            cell.bubbleWidth.constant = 200
        }
        if msg.recieverid == FIRAuth.auth()?.currentUser?.uid
        {
            cell.imgUser.isHidden = false
            cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2
            cell.imgUser.layer.masksToBounds = true
            cell.imgUser.sd_setImage(with: URL.init(string: user.profileImageUrl!))
            cell.bubbleTrailing.constant = view.frame.width-(52+cell.bubbleWidth.constant)
            cell.vwBubbleView.backgroundColor = UIColor(r: 225, g: 225, b: 225)
            cell.textView.textColor = UIColor.black
        }
        if let imageUrl = messageData[indexPath.item].imageUrl
        {
            cell.imgMessage.isHidden = false
            cell.imgMessage.sd_setImage(with: URL.init(string: imageUrl))
            cell.vwBubbleView.backgroundColor = UIColor.clear
            cell.imgMessage.isUserInteractionEnabled = true
            
            if messageData[indexPath.item].videoUrl == nil
            {
                cell.imgMessage.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(HandleTapOnRealImage(_:))))
            }
            else
            {
                cell.imgPlay.isHidden = false
                cell.vwBubbleView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(playVideoOnView(_:))))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 80
        let msgObject = messageData[indexPath.item]
        if let msg = msgObject.message
        {
            height = self.getSizeOfCell(msg).height + 18
        }
        else if msgObject.imageUrl != nil
        {
            let newWidth = msgObject.imageWidth?.floatValue
            let newHeight = msgObject.imageHeight?.floatValue
            height = CGFloat(newHeight! * 200 / newWidth!)
        }
        return CGSize.init(width: view.frame.width, height: height)
    }
    
    func getSizeOfCell(_ string:String) -> CGRect {
    
        return NSString(string: string).boundingRect(with: CGSize.init(width: 200, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)], context: nil)
    }
    @IBAction func btnAttachData(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.isEditing = true
        imagePicker.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
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
        if let url = info[UIImagePickerControllerMediaURL] as? NSURL
        {
            let uniqueString = UUID().uuidString
            let storage = FIRStorage.storage().reference().child("Message_Video").child("\(uniqueString).mov")
            storage.putFile(url as URL, metadata: nil, completion: { (meta, error) in
                if error != nil
                {
                    return
                }
                
                if let videoUrl = meta?.downloadURL()?.absoluteString
                {
                    let thumbNailImage = self.thumbNailImageOfVideo(url as URL)
                    self.UploadTheMessageImages(thumbNailImage!, complition: { (imageurl) in
                        let Value = [MessageTable_videoUrl:videoUrl as AnyObject, MessageTable_imageUrl:imageurl as AnyObject,MessageTable_imageWidth:thumbNailImage?.size.width as AnyObject,MessageTable_imageHeight:thumbNailImage?.size.height as AnyObject] as [String : AnyObject]
                        self.SaveTheMessageData(Value)
                    })
                }
            })
        }
        else
        {
            if let PickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            {
                self.UploadTheMessageImages(PickedImage, complition: { (url) in
                    let Value = [MessageTable_imageUrl:url,MessageTable_imageWidth:PickedImage.size.width,MessageTable_imageHeight:PickedImage.size.height] as [String : AnyObject]
                    self.SaveTheMessageData(Value)
                })
            }
            else if let PickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            {
                self.UploadTheMessageImages(PickedImage, complition: { (url) in
                    let Value = [MessageTable_imageUrl:url,MessageTable_imageWidth:PickedImage.size.width,MessageTable_imageHeight:PickedImage.size.height] as [String : AnyObject]
                    self.SaveTheMessageData(Value)
                })
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func thumbNailImageOfVideo(_ url:URL) -> UIImage? {
        let assest = AVAsset.init(url: url)
        let assetGenerator = AVAssetImageGenerator.init(asset: assest)
        
        do
        {
            let thumbNailCgImage = try assetGenerator.copyCGImage(at: CMTime.init(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage.init(cgImage: thumbNailCgImage)
        }
        catch let error
        {
            
        }
        return nil
    }
    
    func UploadTheMessageImages(_ image:UIImage, complition:@escaping (_ imageUrl:String) -> Void)
    {
        let uniqueString = UUID().uuidString
        let storage = FIRStorage.storage().reference().child("Message_Images").child("\(uniqueString).jpg")
        let datFile = UIImageJPEGRepresentation(image, 0.2)
        storage.put(datFile!, metadata: nil, completion: { (meta, error) in
            if let url = meta?.downloadURL()?.absoluteString
            {
                complition(url)
            }
        })
    }
    
    func SaveTheMessageData(_ property:[String:AnyObject]) {
        let ref = FIRDatabase.database().reference().child(MessageTable)
        let newRef = ref.childByAutoId()
        let senderId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        var newValue = property
        
        newValue[MessageTable_recieverId] = self.user!.id! as AnyObject
        newValue[MessageTable_senderId] = senderId as AnyObject
        newValue[MessageTable_timeStamp] = String(timeStamp) as AnyObject
        
        newRef.updateChildValues(newValue) { (error, ref) in
            if error != nil{
                return
            }
            self.txtMessage.text = ""
            self.txtMessage.resignFirstResponder()
            let messgeRef = FIRDatabase.database().reference().child(UserMessageTable).child(senderId).child(self.user!.id!)
            messgeRef.updateChildValues([ref.key:1])
            
            let messgeRef1 = FIRDatabase.database().reference().child(UserMessageTable).child(self.user!.id!).child(senderId)
            messgeRef1.updateChildValues([ref.key:1])
        }
    }
    
    //MARK: - Zooming Effect
    var startingFrame : CGRect?
    var BackgroundView : UIView?
    var ImageViewZoom : UIImageView?
    func HandleTapOnRealImage(_ tapGuesture:UITapGestureRecognizer) {
        if let imageView = tapGuesture.view as? UIImageView
        {
            let msg = self.messageData[imageView.tag]
            if msg.videoUrl != nil
            {
                self.playVideoOnView(imageView.superview?.gestureRecognizers![0] as! UITapGestureRecognizer)
                return
            }
            
            startingFrame = imageView.convert(imageView.frame, to: self.view)
            if let keyWindow = UIApplication.shared.keyWindow
            {
                BackgroundView = UIView.init(frame: keyWindow.frame)
                BackgroundView?.backgroundColor = UIColor.black
                keyWindow.addSubview(BackgroundView!)
                BackgroundView?.isUserInteractionEnabled = true
                ImageViewZoom = UIImageView.init(frame: startingFrame!)
                ImageViewZoom?.image = imageView.image
                keyWindow.addSubview(ImageViewZoom!)
                
                BackgroundView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(HandleZoomOut(_:))))
                
                BackgroundView?.alpha = 0.0
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.BackgroundView?.alpha = 1.0
                    let Height = keyWindow.frame.size.width * imageView.frame.size.height / imageView.frame.size.width
                    self.ImageViewZoom?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.size.width, height: Height)
                    self.ImageViewZoom?.center = keyWindow.center
                }, completion: nil)
            }
        }
    }
    
    func HandleZoomOut(_ tapGuesture:UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.BackgroundView?.alpha = 0.0
            self.ImageViewZoom?.frame = self.startingFrame!
            self.ImageViewZoom?.layer.cornerRadius = 16.0
            self.ImageViewZoom?.layer.masksToBounds = true
        }, completion: { (completed) in
            self.BackgroundView?.removeFromSuperview()
            self.ImageViewZoom?.removeFromSuperview()
        })
        
    }
    
    //MARK: - Playing Video
    
    var videoPlayer:AVPlayer!
    var videoLayer:AVPlayerLayer!
    var playerView:UIView?
    var playerUrl:String!
    func playVideoOnView(_ tapGuesture:UITapGestureRecognizer) {
        playerView = tapGuesture.view
        let indexPath = IndexPath.init(item: (playerView?.tag)!, section: 0)
        self.stopPlaying()
        let cell = clMessage.cellForItem(at: indexPath) as! ChatViewCell
        cell.vwIndicatorView.isHidden = false
        cell.imgPlay.isHidden = true
        if let videoUrl = messageData[(playerView?.tag)!].videoUrl
        {
            playerUrl = videoUrl
            self.perform(#selector(self.PlayVideo(_:)), with: videoUrl, afterDelay: 0.01)
        }
        
    }
    
    func PlayVideo(_ videoUrl:String) {
        videoPlayer = AVPlayer.init(url: URL.init(string: videoUrl)!)
        videoLayer = AVPlayerLayer.init(player: videoPlayer)
        videoLayer.frame = (playerView?.bounds)!
        playerView?.layer.addSublayer(videoLayer)
        playerView?.isHidden = false
        videoPlayer.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func stopPlaying() {
        let indexPath = IndexPath.init(item: (playerView?.tag)!, section: 0)
        if let cell = clMessage.cellForItem(at: indexPath) as? ChatViewCell
        {
            cell.vwIndicatorView.isHidden = true
            cell.imgPlay.isHidden = false
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        if videoLayer != nil
        {
            videoLayer.removeFromSuperlayer()
        }
        if videoLayer != nil
        {
            videoPlayer.pause()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if playerView != nil
        {
            let rect = playerView?.convert((playerView?.frame)!, to: self.view)
            if rect?.intersects(clMessage.frame) == false
            {
                self.stopPlaying()
            }
        }
        
    }
}
