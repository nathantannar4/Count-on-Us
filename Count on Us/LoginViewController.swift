//
//  LoginViewController.swift
//  WESST
//
//  Created by Nathan Tannar on 2016-06-12.
//  Copyright © 2016 NathanTannar. All rights reserved.
//


import UIKit
import Former
import Parse
import Agrume
import SVProgressHUD

final class LoginViewController: FormViewController {
    
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: #selector(loginButtonPressed))
        title = "Login"
        tableView.contentInset.top = 50
        tableView.contentInset.bottom = 0
        
        // Clear any previous user data
        Profile.sharedInstance.clear()
        
        // Populate table
        configure()
    }
    
    func loginButtonPressed(sender: UIBarButtonItem) {
        if Profile.sharedInstance.email!.characters.count == 0 {
            displayAlert("", message: "Email field is empty")
            return
        } else if Profile.sharedInstance.password!.characters.count == 0 {
            displayAlert("", message: "Password field is empty")
            
        } else {
            SVProgressHUD.showWithStatus("Signing In")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
                self.login()
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    SVProgressHUD.dismiss()
                })
            })

        }
    }
    
    
    // MARK: Private
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private func login() {
        print("Signing in...")
        PFUser.logInWithUsernameInBackground(Profile.sharedInstance.email!, password: Profile.sharedInstance.password!) { (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                
                // User login was a success
                // Load user into local data and dismiss login view controller
                PushNotication.parsePushUserAssign()
                Profile.sharedInstance.loadUser()
                self.dismissViewControllerAnimated(true, completion: { let banner = Banner(title: "Welcome Back!", subtitle: "\(PFUser.currentUser()!.valueForKey(PF_USER_FULLNAME)!)", image: UIImage(named: "Icon"), backgroundColor: WESST_COLOR)
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.0) })
                
            } else {
                print(error)
                self.displayAlert("Oops", message: (error?.description)!)
                
            }
        }
    }
    
    private func configure() {
        
        // Create RowFomers
        let emailRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Email"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your email"
                $0.text = Profile.sharedInstance.email
            }.onTextChanged {
                Profile.sharedInstance.email = $0
        }
        let passwordRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Password"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.textField.secureTextEntry = true
            }.configure {
                $0.placeholder = "Add your password"
                $0.text = Profile.sharedInstance.password
            }.onTextChanged {
                Profile.sharedInstance.password = $0
        }
        
        // Create SectionFormers
        
        let requiredSection = SectionFormer(rowFormer: emailRow, passwordRow)
        
        former.append(sectionFormer: requiredSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
        former.reload()
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}