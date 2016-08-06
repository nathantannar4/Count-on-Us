//
//  EditProfileViewController.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//
//  Modified by Nathan Tannar

import UIKit
import Former
import Parse
import Agrume

final class EditProfileViewController: FormViewController {

    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(saveButtonPressed))
        configure()
    }
    
    func saveButtonPressed(sender: UIBarButtonItem) {
        Profile.sharedInstance.saveUser()
    }
    
    // MARK: Private
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
  
    
    private lazy var imageRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell")) {
            $0.iconView.image = Profile.sharedInstance.image
            }.configure {
                $0.text = "Choose profile image from library"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.former.deselect(true)
                self?.presentImagePicker()
        }
    }()
    
    private lazy var onlyImageRow: LabelRowFormer<ImageCell> = {
        LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {
            $0.displayImage.image = Profile.sharedInstance.image
            }.configure {
                $0.rowHeight = 200
            }
            .onSelected({ (cell: LabelRowFormer<ImageCell>) in
                if Profile.sharedInstance.image != nil {
                    let agrume = Agrume(image: cell.cell.displayImage.image!)
                    agrume.showFrom(self)
                }
        })
    }()
    
    private func configure() {
        title = "Edit Profile"
        tableView.contentInset.top = 20
        tableView.contentInset.bottom = 0
        
        // Create RowFomers
        
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
                $0.pickerItems = OFFICES.map {
                    InlinePickerItem(title: $0)
                }
                if let office = Profile.sharedInstance.office {
                    $0.selectedRow = OFFICES.indexOf(office) ?? 0
                }
            }.onValueChanged {
                Profile.sharedInstance.office = $0.title
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
        let introductionRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFontOfSize(15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your self-introduction"
                $0.text = Profile.sharedInstance.introduction
                $0.rowHeight = 200
            }.onTextChanged {
                Profile.sharedInstance.introduction = $0
        }
        
        // Create SectionFormers
        
        let imageSection = SectionFormer(rowFormer: onlyImageRow, imageRow).set(headerViewFormer: Utilities.createHeader("Profile Image"))
        
        let introductionSection = SectionFormer(rowFormer: introductionRow).set(headerViewFormer: Utilities.createHeader("Introduction"))
        
        let aboutSection = SectionFormer(rowFormer: nameRow, locationRow, jobRow, phoneRow).set(headerViewFormer: Utilities.createHeader("About")).set(footerViewFormer: Utilities.createFooter(""))
        
        former.append(sectionFormer: imageSection, introductionSection, aboutSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = false
        presentViewController(picker, animated: true, completion: nil)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        var imageToBeSaved = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        Profile.sharedInstance.image = image
        imageRow.cellUpdate {
            $0.iconView.image = image
        }
        onlyImageRow.cellUpdate {
            $0.displayImage.image = image
        }

        
        if image.size.width > 300 {
            let resizeFactor = 300 / image.size.width
            
            imageToBeSaved = Images.resizeImage(image, width: resizeFactor * image.size.width, height: resizeFactor * image.size.height)!
        }
        
        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(imageToBeSaved, 0.6)!)
        pictureFile!.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                print("Network error")
            }
        }
        
        let user = PFUser.currentUser()!
        user[PF_USER_PICTURE] = pictureFile
        user.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                print("Network error")
                let banner = Banner(title: "Network Error", subtitle: "Image could not be saved", image: UIImage(named: "Icon"), backgroundColor: SAP_COLOR)
                banner.dismissesOnTap = true
                banner.show(duration: 1.0)
            }
            else {
                let banner = Banner(title: "Image Saved", subtitle: nil, image: UIImage(named: "Icon"), backgroundColor: SAP_COLOR)
                banner.dismissesOnTap = true
                banner.show(duration: 1.0)
            }
        }
        

    }

}