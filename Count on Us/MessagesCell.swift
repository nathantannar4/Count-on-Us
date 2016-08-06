//
//  MessagesCell.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/3/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MessagesCell: UITableViewCell {
    
    @IBOutlet var userImage: PFImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var counterLabel: UILabel!
    
    func bindData(message: PFObject) {
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.layer.masksToBounds = true
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = WESST_COLOR.CGColor
        
        
        let id = message[PF_MESSAGES_GROUPID] as? String
        
        
        if id?.characters.count > 10 {
            let lastUser = message[PF_MESSAGES_LASTUSER] as? PFUser
            if lastUser != PFUser.currentUser()! {
                userImage.file = lastUser?[PF_USER_PICTURE] as? PFFile
                userImage.loadInBackground()
            }
        }
         
        
        descriptionLabel.text = message[PF_MESSAGES_DESCRIPTION] as? String
        lastMessageLabel.text = message[PF_MESSAGES_LASTMESSAGE] as? String
        
        let date = message[PF_MESSAGES_UPDATEDACTION] as! NSDate
        var interval = NSDate().minutesAfterDate(date)
        
        var dateString = ""
        if interval < 60 {
            if interval == 0 {
                dateString = "Now"
            }
            else if interval <= 1 {
                dateString = "1 minutes ago"
            }
            else {
                dateString = "\(interval) minutes ago"
            }
        }
        else {
            interval = NSDate().hoursAfterDate(date)
            if interval < 24 {
                if interval <= 1 {
                    dateString = "1 hour ago"
                }
                else {
                    dateString = "\(interval) hours ago"
                }
            }
            else {
                interval = NSDate().daysAfterDate(date)
                if interval <= 1 {
                    dateString = "1 day ago"
                }
                else {
                    dateString = "\(interval) days ago"
                }
            }
        }
        timeElapsedLabel.text = dateString
        
        let counter = message[PF_MESSAGES_COUNTER]!.integerValue
        counterLabel.text = (counter == 0) ? "" : "\(counter) new"
    }
    
}
