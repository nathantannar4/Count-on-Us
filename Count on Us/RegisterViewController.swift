//
//  RegisterViewController.swift
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

final class RegisterViewController: FormViewController {
    
    var passwordMatch = ""
    
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .Plain, target: self, action: #selector(registerButtonPressed))
        title = "Registration"
        tableView.contentInset.top = 0
        tableView.contentInset.bottom = 0
        
        // Clear any previous user data
        Profile.sharedInstance.clear()
        
        // Populate table
        configure()
    }
    
    func registerButtonPressed(sender: UIBarButtonItem) {
        
        // Invalid entry checks
        if Profile.sharedInstance.name!.characters.count == 0 {
            displayAlert("", message: "You must enter a name")
        }
        else if Profile.sharedInstance.password!.characters.count == 0 {
            print("Password must be set.")
            displayAlert("", message: "You must enter a password")
        }
        else if Profile.sharedInstance.password! != passwordMatch {
            displayAlert("", message: "Your passwords do not match")
        }
        else if Profile.sharedInstance.email!.characters.count == 0 {
            displayAlert("", message: "You must enter an email")
        }
        else if allSchools.contains(Profile.sharedInstance.school!) == false {
            displayAlert("", message: "You must choose your school")
        } else {
            
            // Checks passed, register user
            SVProgressHUD.showWithStatus("Setting Things Up")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
                self.saveToParse()
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    SVProgressHUD.dismiss()
                })
            })
        }
    }
    
    
    // MARK: Private
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private func saveToParse() {
        let user = PFUser()
        user.username = Profile.sharedInstance.email!
        user.password = Profile.sharedInstance.password!
        user.email = Profile.sharedInstance.email!
        user[PF_USER_FULLNAME] = Profile.sharedInstance.name!
        user[PF_USER_GENDER] = Profile.sharedInstance.gender
        user[PF_USER_INFO] = ""
        user[PF_USER_BIRTHDAY] = Profile.sharedInstance.birthDay!
        user[PF_USER_SCHOOL] = Profile.sharedInstance.school!
        user[PF_USER_PHONE] = Profile.sharedInstance.phoneNumber!
        user[PF_USER_MASTER] = false
        user["walkthrough"] = true
        user["admin"] = []
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                PushNotication.parsePushUserAssign()
                Profile.sharedInstance.loadUser()
                print("Succeeded.")
                self.dismissViewControllerAnimated(true, completion: { let banner = Banner(title: "Welcome", subtitle: "\(PFUser.currentUser()!.valueForKey(PF_USER_FULLNAME)!)", image: UIImage(named: "Icon"), backgroundColor: WESST_COLOR)
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
        let verifyRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Password"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.textField.secureTextEntry = true
            }.configure {
                $0.placeholder = "Retype your password"
            }.onTextChanged {
                self.passwordMatch = $0
        }
        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Name"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your name"
                $0.text = Profile.sharedInstance.name
            }.onTextChanged {
                Profile.sharedInstance.name = $0
        }
        let locationRow = InlinePickerRowFormer<ProfileLabelCell, String>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "School"
            }.configure {
                let schools = allSchools
                $0.pickerItems = schools.map {
                    InlinePickerItem(title: $0)
                }
                if let school = Profile.sharedInstance.school {
                    $0.selectedRow = schools.indexOf(school) ?? 0
                }
            }.onValueChanged {
                Profile.sharedInstance.school = $0.title
        }
        let phoneRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Phone"
            $0.textField.keyboardType = .NumberPad
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your phone number"
                $0.text = Profile.sharedInstance.phoneNumber
            }.onTextChanged {
                Profile.sharedInstance.phoneNumber = $0
        }
        let jobRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Title"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your title (if applicable)"
                $0.text = Profile.sharedInstance.job
            }.onTextChanged {
                Profile.sharedInstance.job = $0
        }
        let genderRow = InlinePickerRowFormer<ProfileLabelCell, String>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Gender"
            }.configure {
                let genders = ["Male", "Female", "Neither", "Undefined"]
                $0.pickerItems = genders.map {
                    InlinePickerItem(title: $0)
                }
                if let gender = Profile.sharedInstance.gender {
                    $0.selectedRow = genders.indexOf(gender) ?? 0
                }
            }.onValueChanged {
                Profile.sharedInstance.gender = $0.title
        }
        let yearRow = InlinePickerRowFormer<ProfileLabelCell, String>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Year"
            }.configure {
                let years = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th"]
                $0.pickerItems = years.map {
                    InlinePickerItem(title: $0)
                }
                if let year = Profile.sharedInstance.year {
                    $0.selectedRow = years.indexOf(year) ?? 0
                }
            }.onValueChanged {
                Profile.sharedInstance.year = $0.title
        }
        let optionRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Discipline"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Engineering Option"
                $0.text = Profile.sharedInstance.option
            }.onTextChanged {
                Profile.sharedInstance.option = $0
        }
        let birthdayRow = InlineDatePickerRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Birthday"
            }.configure {
                $0.date = Profile.sharedInstance.birthDay ?? NSDate()
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .Date
            }.displayTextFromDate {
                return String.mediumDateNoTime($0)
            }.onDateChanged {
                Profile.sharedInstance.birthDay = $0
        }
        
        // Create SectionFormers
        
        let requiredSection = SectionFormer(rowFormer: emailRow, passwordRow, verifyRow, nameRow, locationRow).set(headerViewFormer: Utilities.createHeader("Required Details"))
            
        let optionalSection = SectionFormer(rowFormer: jobRow, yearRow, optionRow, phoneRow, genderRow, birthdayRow).set(headerViewFormer: Utilities.createHeader("Optional Details"))
        
        
        former.append(sectionFormer: requiredSection, optionalSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}