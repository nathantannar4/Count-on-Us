//
//  PublicProfileViewController.swift
//  WESST
//
//  Created by Tannar, Nathan on 2016-07-10.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse
import Former
import Agrume
import SVProgressHUD

class PublicProfileViewController: FormViewController  {
    
    var firstLoad = true
    var user: PFObject?
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.currentUser() == nil {
            Utilities.loginUser(self)
        }
        
        if PFUser.currentUser()!.valueForKey(PF_USER_FULLNAME) as? String != user![PF_USER_FULLNAME] as? String {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message", style: .Plain, target: self, action: #selector(messageButtonPressed))
        }
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        configure()
    }
    
    func messageButtonPressed(sender: AnyObject) {
        let user1 = PFUser.currentUser()!
        let user2 = user! as? PFUser
        let chatVC = ChatViewController()
        chatVC.groupId = Messages.startPrivateChat(user1, user2: user2!)
        chatVC.outgoingColor = SAP_COLOR
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }

    
    override func viewDidAppear(animated: Bool) {
        former.removeAll()
        configure()
    }
    
    private lazy var zeroRow: LabelRowFormer<ImageCell> = {
        LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {_ in
            }.configure {
                $0.rowHeight = 0
        }
    }()
    
    
    private func configure() {
        let headerRow = CustomRowFormer<ProfileHeaderCell>(instantiateType: .Nib(nibName: "ProfileHeaderCell")) {
            $0.iconView.backgroundColor = SAP_COLOR
            $0.backgroundLabel.backgroundColor = SAP_COLOR
            $0.nameLabel.text = self.user![PF_USER_FULLNAME] as? String
            $0.schoolLabel.text = self.user![PF_USER_OFFICE] as? String
            $0.titleLabel.text = self.user![PF_USER_TITLE] as? String
            let userImageFile = self.user![PF_USER_PICTURE] as? PFFile
            if userImageFile != nil {
                do {
                    let imageData = try userImageFile!.getData()
                    $0.iconView.image = UIImage(data:imageData)
                } catch _ {}
            }
            
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
            }.onSelected({ (cell: CustomRowFormer<ProfileHeaderCell>) in
                if cell.cell.iconView.image != nil {
                    let agrume = Agrume(image: cell.cell.iconView.image!)
                    agrume.showFrom(self)
                }
            })
        
        let phoneRow = CustomRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Phone"
            $0.titleLabel.textColor = SAP_COLOR
            $0.displayLabel.text = self.user![PF_USER_PHONE] as? String
            }.onSelected { _ in
                self.former.deselect(true)
                
        }
        let emailRow = CustomRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Email"
            $0.titleLabel.textColor = SAP_COLOR
            $0.displayLabel.text = self.user![PF_USER_EMAIL] as? String
            }.onSelected { _ in
                self.former.deselect(true)
        }
        let infoRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Nib(nibName: "DynamicHeightCell")) {
            $0.title = "About Me"
            $0.body = self.user![PF_USER_INFO] as? String
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.titleLabel.textColor = SAP_COLOR
            $0.bodyLabel.font = .systemFontOfSize(15)
            $0.date = ""
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
            }.onSelected { _ in
                self.former.deselect(true)
        }
        
        // Add profile info rows to table
        self.former.append(sectionFormer: SectionFormer(rowFormer: headerRow, infoRow, phoneRow, emailRow))
        self.former.reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User actions
    
    func editButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(EditProfileViewController(), animated: true)
    }
    
    func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        Profile.sharedInstance.clear()
        PushNotication.parsePushUserResign()
        Utilities.postNotification(NOTIFICATION_USER_LOGGED_OUT)
        Utilities.loginUser(self)
    }
}
