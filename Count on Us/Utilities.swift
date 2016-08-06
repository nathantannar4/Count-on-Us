//
//  Utilities.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation
import UIKit
import Former

class Utilities {
    
    class func loginUser(target: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC = storyboard.instantiateViewControllerWithIdentifier("navigationVC") as! UINavigationController
        target.presentViewController(welcomeVC, animated: false, completion: nil)
    }
    
    class func postNotification(notification: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: nil)
    }
    
    class func timeElapsed(seconds: NSTimeInterval) -> String {
        var elapsed: String
        if seconds < 60 {
            elapsed = "Just now"
        }
        else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            let suffix = (minutes > 1) ? "mins" : "min"
            elapsed = "\(minutes) \(suffix) ago"
        }
        else if seconds < 24 * 60 * 60 {
            let hours = Int(seconds / (60 * 60))
            let suffix = (hours > 1) ? "hours" : "hour"
            elapsed = "\(hours) \(suffix) ago"
        }
        else {
            let days = Int(seconds / (24 * 60 * 60))
            let suffix = (days > 1) ? "days" : "day"
            elapsed = "\(days) \(suffix) ago"
        }
        return elapsed
    }
    
    class func dateToString(time: NSDate) -> String {
        var interval = NSDate().minutesAfterDate(time)
        if interval < 60 {
            if interval <= 1 {
                return "Just Now"
            }
            else {
                return "\(interval) minutes ago"
            }
        }
        else {
            interval = NSDate().hoursAfterDate(time)
            if interval < 24 {
                if interval <= 1 {
                    return "1 hour ago"
                }
                else {
                    return "\(interval) hours ago"
                }
            }
            else {
                interval = NSDate().daysAfterDate(time)
                if interval <= 1 {
                    return "1 day ago"
                }
                else {
                    return "\(interval) days ago"
                }
            }
        }
    }
    
    class func createHeader(text: String) -> ViewFormer {
        return LabelViewFormer<FormLabelHeaderView>()
            .configure {
                $0.viewHeight = 40
                $0.text = text
        }
    }
    
    class func createFooter(text: String) -> ViewFormer {
        return LabelViewFormer<FormLabelFooterView>()
            .configure {
                $0.text = text
                $0.viewHeight = 40
        }
    }
}

