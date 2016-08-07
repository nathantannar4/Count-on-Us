//
//  FoodMapViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse
import Former
import Agrume

class MainViewController: FormViewController {
    
    var refreshControl: UIRefreshControl!
    var firstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: "Food")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                for object in objects! {
    
                    var dayStats = [NSDate]()
                    var dayStatsCount = [CGFloat]()
                    for date in 1...30 {
                        dayStats.append(NSDate().dateBySubtractingDays(date))
                        dayStatsCount.append(CGFloat(Int(arc4random_uniform(50))))
                    }
                    object["dayStats"] = dayStats
                    object["dayStatsCount"] = dayStatsCount
                    object.saveInBackgroundWithBlock({ (sucess: Bool, error: NSError?) in
                        if error != nil {
                            print(error)
                        }
                    })
                }
            }
        }
        
        
        
        
        
        
        
        // Configure Navbar
        title = "Home"
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        
        if PFUser.currentUser() == nil {
            Utilities.loginUser(self)
        }
        
        Profile.sharedInstance.user = PFUser.currentUser()
        Profile.sharedInstance.loadUser()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.former.append(sectionFormer: SectionFormer(rowFormer: onlyImageRow))
        self.former.reload()
        configure()
    }
    
    func refresh(sender:AnyObject)
    {
        // Updating your data here...
        former.remove(section: 1)
        former.remove(section: 1)
        self.refreshControl?.endRefreshing()
        configure()
    }
    
    private lazy var onlyImageRow: LabelRowFormer<ImageCell> = {
        LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {
            $0.displayImage.image = UIImage(named: "SAP_Logo.png")
            }.configure {
                $0.rowHeight = 175
            }
            .onSelected({ (cell: LabelRowFormer<ImageCell>) in
                self.former.deselect(true)
                let agrume = Agrume(image: cell.cell.displayImage.image!)
                    agrume.showFrom(self)
            })
    }()
    
    private func configure() {
        
        var invites = [CustomRowFormer<EventFeedCell>]()
        var organizing = [CustomRowFormer<EventFeedCell>]()
        
        let query = PFQuery(className: "Events")
        query.whereKey("inviteTo", containedIn: [PFUser.currentUser()!])
        query.whereKey("start", greaterThan: NSDate().dateBySubtractingHours(12))
        query.addAscendingOrder(PF_CREATEDAT)
        query.includeKey("organizer")
        query.includeKey("business")
        query.findObjectsInBackgroundWithBlock({ (invitations: [PFObject]?, error: NSError?) in
            if error == nil {
                if invitations != nil {
                    for invite in invitations! {
                        if (invite["organizer"] as! PFUser).objectId! == PFUser.currentUser()!.objectId! {
                            organizing.append(CustomRowFormer<EventFeedCell>(instantiateType: .Nib(nibName: "EventFeedCell")) {
                                let user = invite["organizer"] as! PFUser
                                let business = invite["business"] as? PFObject
                                $0.title.text = business![PF_BUSINESS_NAME] as? String
                                $0.timeDay.text = invite["info"] as? String
                                let startDate = invite["start"] as? NSDate
                                let endDate = invite["end"] as? NSDate
                                let interval = endDate!.timeIntervalSinceDate(startDate!)
                                
                                $0.location.text = "\(startDate!.shortTimeString) on \(startDate!.longDateString) for \((Int(interval) + 1)/60) minutes"
                                $0.organizer.text = "Organized By: \(user.valueForKey("fullname") as! String)"
                                $0.attendence.text = "\(invite["confirmed"].count) Confirmed, \(invite["maybe"].count) Maybe"
                                }.configure {
                                    $0.rowHeight = UITableViewAutomaticDimension
                                }.onSelected {_ in
                                    let detailVC = EventDetailViewController()
                                    detailVC.event = invite
                                    detailVC.business = invite["business"] as? PFObject
                                    self.navigationController?.pushViewController(detailVC, animated: true)
                                })
                        } else {
                            invites.append(CustomRowFormer<EventFeedCell>(instantiateType: .Nib(nibName: "EventFeedCell")) {
                                let user = invite["organizer"] as! PFUser
                                let business = invite["business"] as? PFObject
                                $0.title.text = business![PF_BUSINESS_NAME] as? String
                                $0.timeDay.text = invite["info"] as? String
                                let startDate = invite["start"] as? NSDate
                                let endDate = invite["end"] as? NSDate
                                let interval = endDate!.timeIntervalSinceDate(startDate!)
                                
                                $0.location.text = "\(startDate!.shortTimeString) on \(startDate!.longDateString) for \((Int(interval) + 1)/60) minutes"
                                $0.organizer.text = "Organized By: \(user.valueForKey("fullname") as! String)"
                                $0.attendence.text = "\(invite["confirmed"].count) Confirmed, \(invite["maybe"].count) Maybe"
                                }.configure {
                                    $0.rowHeight = UITableViewAutomaticDimension
                                }.onSelected {_ in
                                    let detailVC = EventDetailViewController()
                                    detailVC.event = invite
                                    detailVC.business = invite["business"] as? PFObject
                                    self.navigationController?.pushViewController(detailVC, animated: true)
                                })
                        }
                        
                    }
                    self.former.append(sectionFormer: SectionFormer(rowFormers: invites).set(headerViewFormer: Utilities.createHeader("Invitations")))
                    self.former.append(sectionFormer: SectionFormer(rowFormers: organizing).set(headerViewFormer: Utilities.createHeader("Organizing")))
                    self.former.reload()
                    self.firstLoad = false
                }
            }
        })
        
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !firstLoad {
            refresh(self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

