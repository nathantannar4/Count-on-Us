//
//  CreateInvitationViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Former
import Parse

final class CreateInvitationViewController: FormViewController, SelectMultipleViewControllerDelegate {
    
    var business: PFObject!
    
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(sendButtonPressed))
        configure()
        Event.sharedInstance.clear()
    }
    
    func sendButtonPressed(sender: AnyObject) {
        if Event.sharedInstance.inviteTo.count > 0 {
            Event.sharedInstance.business = business
            Event.sharedInstance.create()
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let banner = Banner(title: "Oops!", subtitle: "You forgot to select invitation recipiants", image: nil, backgroundColor: SAP_COLOR)
            banner.dismissesOnTap = true
            banner.show(duration: 1.0)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "inviteColleagues" {
            let selectMultipleVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! SelectMultipleViewController
            selectMultipleVC.delegate = self
        }
    }
    
    func didSelectMultipleUsers(selectedUsers: [PFUser]!) {
        
        // Returns current user in selectedUsers so they must be removed
        var inviteUsers = selectedUsers
        let index = inviteUsers.indexOf(PFUser.currentUser()!)
        inviteUsers.removeAtIndex(index!)
        Event.sharedInstance.inviteTo = selectedUsers
        self.former.remove(section: 0)
        let userRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Nib(nibName: "DynamicHeightCell")) {
            $0.title = "Send Invite To:"
            var invitedUsers = ""
            for user in inviteUsers {
                invitedUsers = invitedUsers.stringByAppendingString(user[PF_USER_FULLNAME] as! String) + ", "
            }
            invitedUsers = invitedUsers.stringByPaddingToLength(invitedUsers.characters.count - 2, withString: invitedUsers, startingAtIndex: 0)
            $0.body = invitedUsers
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.titleLabel.textColor = SAP_COLOR
            $0.bodyLabel.font = .systemFontOfSize(15)
            $0.date = ""
            $0.selectionStyle = .None
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
            }.onSelected { _ in
                self.former.deselect(true)
        }
        self.former.insert(sectionFormer: SectionFormer(rowFormer: userRow), toSection: 0)
        self.former.reload()
    }
    
    let createMenu: ((String, (() -> Void)?) -> RowFormer) = { text, onSelected in
        return LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = SAP_COLOR
            $0.titleLabel.font = .boldSystemFontOfSize(16)
            $0.accessoryType = .DisclosureIndicator
            }.configure {
                $0.text = text
            }.onSelected { _ in
                onSelected?()
        }
    }
    
    // MARK: Private
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private lazy var zeroRow: LabelRowFormer<ImageCell> = {
        LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {_ in
            }.configure {
                $0.rowHeight = 0
        }
    }()
    
    private func configure() {
        title = "Invitation"
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10
        
        // Create RowFomers
        
        let endRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "End"
            $0.titleLabel.textColor = SAP_COLOR
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFontOfSize(15)
            Event.sharedInstance.end = NSDate()
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .DateAndTime
            }.onDateChanged {
                Event.sharedInstance.end = $0
            }.displayTextFromDate(String.mediumDateShortTime)
        
        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start"
            $0.titleLabel.textColor = SAP_COLOR
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFontOfSize(15)
            Event.sharedInstance.start = NSDate()
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .DateAndTime
            }.onDateChanged {
                Event.sharedInstance.start = $0
            }.displayTextFromDate(String.mediumDateShortTime)
        
        let infoRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFontOfSize(15)
            }.configure {
                $0.placeholder = "Tap to edit..."
                $0.rowHeight = 200
            }.onTextChanged {
                Event.sharedInstance.info = $0
        }
        let inviteRow = createMenu("Invite Colleagues") { [weak self] in
            self?.former.deselect(true)
            self?.performSegueWithIdentifier("inviteColleagues", sender: self)
        }
        
        // Create SectionFormers
        
        let dateSection = SectionFormer(rowFormer: startRow, endRow)
            .set(headerViewFormer: Utilities.createHeader("Time & Day"))
        let noteSection = SectionFormer(rowFormer: infoRow)
            .set(headerViewFormer: Utilities.createHeader("Invitation Details"))
        
        former.append(sectionFormer: SectionFormer(rowFormer: zeroRow), dateSection, noteSection, SectionFormer(rowFormer: inviteRow)).onCellSelected { [weak self] _ in
            self?.formerInputAccessoryView.update()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        Event.sharedInstance.clear()
    }
}
