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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Navbar
        title = "Home"
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        
        if PFUser.currentUser() == nil {
            Utilities.loginUser(self)
        }
        
        Profile.sharedInstance.user = PFUser.currentUser()
        Profile.sharedInstance.loadUser()
        
        configure()
    }
    
    private lazy var onlyImageRow: LabelRowFormer<ImageCell> = {
        LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {
            $0.displayImage.image = UIImage(named: "SAP_Logo.png")
            }.configure {
                $0.rowHeight = 200
            }
            .onSelected({ (cell: LabelRowFormer<ImageCell>) in
                self.former.deselect(true)
                let agrume = Agrume(image: cell.cell.displayImage.image!)
                    agrume.showFrom(self)
            })
    }()
    
    private func configure() {
        
        self.former.append(sectionFormer: SectionFormer(rowFormer: onlyImageRow))
        self.former.reload()
        
        var invites = [CustomRowFormer<EventFeedCell>]()
        
        let query = PFQuery(className: "Events")
        query.whereKey("inviteTo", containedIn: [PFUser.currentUser()!])
        query.addAscendingOrder(PF_CREATEDAT)
        query.includeKey("organizer")
        query.includeKey("business")
        query.findObjectsInBackgroundWithBlock({ (invitations: [PFObject]?, error: NSError?) in
            if error == nil {
                if invitations != nil {
                    for invite in invitations! {
                        print(invite)
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
                    self.former.append(sectionFormer: SectionFormer(rowFormers: invites).set(headerViewFormer: Utilities.createHeader("Invitations")))
                    self.former.reload()
                }
            }
        })
        
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

