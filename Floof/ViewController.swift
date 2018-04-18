//
//  ViewController.swift
//  Floof
//
//  Created by Tommy Mallow on 4/8/18.
//  Copyright © 2018 Marshmallow. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var signupModeActive = true;
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var username: UITextField!
    
    @IBAction func signupOrLogin(_ sender: Any) {
        
        if email.text == "" || password.text == "" {
            
            displayAlert(title: "Error in form", message: "Please enter an email and password")
            
        } else {
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            activityIndicator.center = self.view.center
            
            activityIndicator.hidesWhenStopped = true
            
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if (signupModeActive) {
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                user.email = email.text
                
                user.signUpInBackground(block: {(success, error) in
                    
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if let error = error {
                        
                        self.displayAlert(title: "Could not sign you up", message: error.localizedDescription)
                        
                        print (error)
                    } else {
                        
                        print("Signed up!")
                        
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                })
            } else {
                
                PFUser.logInWithUsername(inBackground: email.text!, password: password.text!) { (user, error) in
                    
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if (user != nil) {
                        
                        print("Login successful!")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                        
                    } else {
                        
                        var errorText = "Unkown error: please try again"
                        
                        if let error = error {
                            errorText = error.localizedDescription
                        }
                        
                        self.displayAlert(title: "Could not sign you up", message: errorText)
                    }
                    
                }
                
            }
        }
        
    }
    
    @IBOutlet weak var signupOrLoginButton: UIButton!
    
    
    @IBAction func switchLoginMode(_ sender: Any) {
        
        if (signupModeActive) {
            signupModeActive = false

            username.alpha = 0;
            
            signupOrLoginButton.setTitle("Log In", for: [])
            
            switchLoginModeButton.setTitle("Sign Up", for: [])
        } else {
            signupModeActive = true
            
            username.alpha = 1;
            
            signupOrLoginButton.setTitle("Sign Up", for: [])
            
            switchLoginModeButton.setTitle("Log In", for: [])
        }
        
    }
    
    
    @IBOutlet weak var switchLoginModeButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
            self.performSegue(withIdentifier: "showUserTable", sender: self)
        }
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

