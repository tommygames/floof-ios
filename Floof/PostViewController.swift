//
//  PostViewController.swift
//  Floof
//
//  Created by Tommy Mallow on 4/8/18.
//  Copyright © 2018 Marshmallow. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var videoToPost: PFFile!
    @IBOutlet weak var comment: UITextField!
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let tempVideo = info[UIImagePickerControllerMediaURL] as? NSURL
        
        let videoData = NSData(contentsOfFile: (tempVideo?.relativePath)!)

        videoToPost = PFFile(name:"video.mov", data:(videoData as Data?)!)!
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func postImage(_ sender: Any) {
        
        
        if let video = videoToPost {
            
            let post = PFObject(className: "Post")
            
            post["message"] = comment.text
            post["userid"] = PFUser.current()?.objectId
            post["likes"] = 0
            
                let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                
                activityIndicator.center = self.view.center
                
                activityIndicator.hidesWhenStopped = true
                
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                
                view.addSubview(activityIndicator)
                
                activityIndicator.startAnimating()
                
                UIApplication.shared.beginIgnoringInteractionEvents()
            
                post["videoFile"] = video
                post.saveInBackground { (success, error) in
                    
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if success {
                        
                        self.displayAlert(title: "Video Posted", message: "Your video has been posted successfully")
                        
                        self.comment.text = ""
                        
                        self.videoToPost = nil
                        
                    } else {
                        
                        self.displayAlert(title: "Video could not be posted", message: "Please try again later")
                        
                    }
                    
                }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
