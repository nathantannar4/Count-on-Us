//
//  Profile.swift
//  WESST
//
//  Created by Tannar, Nathan on 2016-07-10.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse

final class Profile {
    
    static let sharedInstance = Profile()
    
    var user: PFUser?
    var image: UIImage?
    var name: String?
    var introduction: String?
    var phoneNumber: String?
    var job: String?
    var email: String?
    var password: String?
    var office: String?
    
    func clear() {
        user = nil
        image = nil
        name = ""
        introduction = ""
        phoneNumber = ""
        job = ""
        email = ""
        password = ""
        office = ""
    }
    
    func loadUser() {
        if let user = user {
            
            let userImageFile = user[PF_USER_PICTURE] as? PFFile
            if userImageFile != nil {
                userImageFile!.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            self.image = UIImage(data:imageData)
                        }
                    }
                }
            }
            
            
            name = user[PF_USER_FULLNAME] as? String
            if (user[PF_USER_PHONE] != nil) {
                phoneNumber = user[PF_USER_PHONE] as? String
            }
            if (user[PF_USER_TITLE] != nil) {
                job = user[PF_USER_TITLE] as? String
            }
            if (user[PF_USER_INFO] != nil) {
                introduction = user[PF_USER_INFO] as? String
            }
            if (user[PF_USER_OFFICE] != nil) {
                office = user[PF_USER_OFFICE] as? String
            }
        }
    }
    
    func saveUser() {
        let fullName = name
        if fullName!.characters.count > 0 {
            let user = PFUser.currentUser()!
            user[PF_USER_FULLNAME] = fullName!
            user[PF_USER_FULLNAME_LOWER] = fullName!.lowercaseString
            user[PF_USER_INFO] = introduction
            user[PF_USER_PHONE] = phoneNumber
            user[PF_USER_TITLE] = job
            user.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                if error == nil {
                    print("Saved")
                    let banner = Banner(title: "Profile Saved", subtitle: nil, image: UIImage(named: "Icon"), backgroundColor: SAP_COLOR)
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.0)
                } else {
                    print("Network error")
                    let banner = Banner(title: "Network Error", subtitle: "Profile could not be saved", image: nil, backgroundColor: SAP_COLOR)
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.0)

                }
            })
        } else {
            let banner = Banner(title: "Oops", subtitle: "You can't leave your name blank!", image: nil, backgroundColor: SAP_COLOR)
            banner.dismissesOnTap = true
            banner.show(duration: 1.0)
        }
    }
}