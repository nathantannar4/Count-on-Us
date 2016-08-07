//
//  Event.swift
//  WESST
//
//  Created by Tannar, Nathan on 2016-07-08.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse

final class Event {
    
    static let sharedInstance = Event()
    
    var organizer: PFUser?
    var inviteTo = [PFUser]()
    var info: String?
    var business: PFObject?
    var start: NSDate?
    var end: NSDate?
    
    func clear() {
        organizer = nil
        inviteTo.removeAll()
        business = nil
        info = nil
        start = NSDate()
        end = NSDate()
    }
    
    func create() {
        let newEvent = PFObject(className: "Events")
        if info != nil {
            newEvent["info"] = info
        } else {
            newEvent["info"] = ""
        }
        newEvent["buiness"] = business
        newEvent["organizer"] = PFUser.currentUser()
        newEvent["inviteTo"] = inviteTo
        newEvent["confirmed"] = []
        newEvent["maybe"] = []
        newEvent["start"] = start
        if Int((end?.timeIntervalSinceDate(start!))!)/60 <= 0 {
            newEvent["end"] = start?.dateByAddingHours(1)
        } else {
            newEvent["end"] = end
        }
        newEvent.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if success {
                let banner = Banner(title: "Invitation Sent", subtitle: nil, image: nil, backgroundColor: SAP_COLOR)
                banner.dismissesOnTap = true
                banner.show(duration: 1.0)
            }
        }
        clear()
    }
}