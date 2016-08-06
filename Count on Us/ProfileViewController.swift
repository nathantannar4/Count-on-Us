//
//  ProfileViewController.swift
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

class ProfileViewController: FormViewController  {
    
    var color = WESST_COLOR
    var firstLoad = true
    var querySkip = 0
    var rowCounter = 0
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI and Table Properties
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        let editButton   = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(editButtonPressed))
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(logoutButtonPressed))
        navigationItem.rightBarButtonItems = [logoutButton, editButton]
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        title = "My Profile"
        tableView.contentInset.top = 0
        tableView.contentInset.bottom = 60
        
        // Load User Data
        if PFUser.currentUser() == nil {
            Utilities.loginUser(self)
        }
        
        Profile.sharedInstance.user = PFUser.currentUser()
        Profile.sharedInstance.loadUser()
    }
    
    override func viewDidAppear(animated: Bool) {
        former.removeAll()
        querySkip = 0
        rowCounter = 0
        configure()
    }
    
    private lazy var zeroRow: LabelRowFormer<ImageCell> = {
        LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {_ in
            }.configure {
                $0.rowHeight = 0
        }
    }()

    
    private lazy var loadMoreSection: SectionFormer = {
        let loadMoreRow = LabelRowFormer<CenterLabelCell>()
            .configure {
                $0.text = "Load More"
            }.onSelected { [weak self] _ in
                self?.former.deselect(true)
                self!.querySkip += 3
                self!.insertPost()
        }
        return SectionFormer(rowFormer: loadMoreRow)
    }()
    
    private func configure() {
        let headerRow = CustomRowFormer<ProfileHeaderCell>(instantiateType: .Nib(nibName: "ProfileHeaderCell")) {
            $0.iconView.backgroundColor = self.color
            $0.backgroundLabel.backgroundColor = self.color
            $0.nameLabel.text = Profile.sharedInstance.user![PF_USER_FULLNAME] as? String
            $0.schoolLabel.text = Profile.sharedInstance.user![PF_USER_SCHOOL] as? String
            $0.titleLabel.text = Profile.sharedInstance.user![PF_USER_TITLE] as? String
            let userImageFile = Profile.sharedInstance.user![PF_USER_PICTURE] as? PFFile
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
            $0.titleLabel.textColor = self.color
            $0.displayLabel.text = Profile.sharedInstance.user![PF_USER_PHONE] as? String
            }.onSelected { _ in
                self.former.deselect(true)
                
        }
        let birthdayRow = CustomRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Birthday"
            $0.titleLabel.textColor = self.color
            $0.displayLabel.text = (Profile.sharedInstance.user![PF_USER_BIRTHDAY] as? NSDate)?.mediumDateString
            }.onSelected { _ in
                self.former.deselect(true)
                
        }
        let emailRow = CustomRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Email"
            $0.titleLabel.textColor = self.color
            $0.displayLabel.text = Profile.sharedInstance.user![PF_USER_EMAIL] as? String
            }.onSelected { _ in
                self.former.deselect(true)
        }
        let yearRow = CustomRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Year"
            $0.titleLabel.textColor = self.color
            $0.displayLabel.text = Profile.sharedInstance.user![PF_USER_YEAR] as? String
            }.onSelected { _ in
                self.former.deselect(true)
        }
        let optionRow = CustomRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Discipline"
            $0.titleLabel.textColor = self.color
            $0.displayLabel.text = Profile.sharedInstance.user![PF_USER_OPTION] as? String
            }.onSelected { _ in
                self.former.deselect(true)
        }
        let infoRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Nib(nibName: "DynamicHeightCell")) {
            $0.title = "About Me"
            $0.body = Profile.sharedInstance.user![PF_USER_INFO] as? String
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.titleLabel.textColor = self.color
            $0.bodyLabel.font = .systemFontOfSize(15)
            $0.date = ""
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
            }.onSelected { _ in
                self.former.deselect(true)
        }
        
        // Add profile info rows to table
        self.former.append(sectionFormer: SectionFormer(rowFormer: headerRow, infoRow, yearRow, optionRow, phoneRow, emailRow, birthdayRow))
        self.former.reload()
        
        let zeroSection = SectionFormer(rowFormer: zeroRow).set(headerViewFormer: Utilities.createHeader("Recent Posts"))
        self.former.append(sectionFormer: zeroSection)
        self.former.reload()
        
        insertEvents()
        insertPost()
    }
    
    private func insertPost() {
        
        let query = PFQuery(className: "Posts")
        query.limit = 3
        query.skip = querySkip
        query.orderByDescending("createdAt")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) in
            if error == nil && posts?.count > 0 {
                for post in posts! {
                    let hasImage = post["hasImage"] as? Bool
                    
                    let dividerRow = CustomRowFormer<DividerCell>(instantiateType: .Nib(nibName: "DividerCell")) {
                        $0.divider.backgroundColor = WESST_COLOR
                        }.configure {
                            $0.rowHeight = 8
                    }
                    
                    let postRow = CustomRowFormer<PostCell>(instantiateType: .Nib(nibName: "PostCell")) {
                        let user = post["user"] as! PFUser
                        $0.username.text = user.valueForKey("fullname") as? String
                        $0.info.font = .systemFontOfSize(16)
                        $0.info.text = post["info"] as? String
                        $0.school.text =  user.valueForKey("school") as? String
                        $0.date.text = Utilities.dateToString(post.createdAt!)
                        
                        if post["replies"] as? Int == 1 {
                            $0.replies.text = "1 reply"
                            
                        } else {
                            $0.replies.text = "\(post["replies"]) replies"
                        }
                        
                        }.configure {
                            $0.rowHeight = UITableViewAutomaticDimension
                        }.onSelected {_ in
                            let detailVC = PostDetailViewController()
                            School.sharedInstance.color = WESST_COLOR
                            detailVC.post = post
                            detailVC.postUser = post["user"] as? PFUser
                            self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                    
                    if  hasImage == true {
                        let imageToBeLoaded = post["image"] as? PFFile
                        if imageToBeLoaded != nil {
                            imageToBeLoaded!.getDataInBackgroundWithBlock {(imageData: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    if let imageData = imageData {
                                        let postImageRow = LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {
                                            $0.displayImage.image = UIImage(data:imageData)!
                                            }.configure {
                                                $0.rowHeight = 200
                                            }.onSelected({ (cell: LabelRowFormer<ImageCell>) in
                                                let agrume = Agrume(image: cell.cell.displayImage.image!)
                                                agrume.showFrom(self)
                                            })
                                        self.former.insert(rowFormer: postImageRow, below: postRow)
                                        self.rowCounter += 1
                                        self.former.reload()
                                    }
                                }
                            }
                        }
                    }
                    
                    self.former.insertUpdate(rowFormers: [postRow, dividerRow], toIndexPath: NSIndexPath(forRow: self.rowCounter, inSection: 2), rowAnimation: .Fade)
                    self.rowCounter += 2
                }
                if self.querySkip == 0 {
                    self.former.append(sectionFormer: self.loadMoreSection)                }
                self.former.reload()
            } else  if self.querySkip != 0 {
                let banner = Banner(title: "No posts could be loaded", subtitle: error?.description, image: nil, backgroundColor: WESST_COLOR)
                banner.dismissesOnTap = true
                banner.show(duration: 1.5)
            }
        }
    }

    
    private func insertEvents() {
        // Add 2 upcoming events user is attending
        
        let eventsSection = SectionFormer(rowFormer: zeroRow)
        
        var eventRow = [CustomRowFormer<EventFeedCell>]()
        var eventDividerRow = [CustomRowFormer<DividerCell>]()
        
        let eventQuery = PFQuery(className:  "Events")
        eventQuery.limit = 2
        eventQuery.orderByAscending("start")
        eventQuery.whereKey("start", greaterThan: NSDate())
        eventQuery.whereKey("confirmed", containedIn: [Profile.sharedInstance.user!])
        eventQuery.includeKey("organizer")
        eventQuery.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) in
            if error == nil {
                if let events = events {
                    var index = 0
                    
                    for event in events {
                        
                        eventDividerRow.append(CustomRowFormer<DividerCell>(instantiateType: .Nib(nibName: "DividerCell")) {
                            $0.divider.backgroundColor = self.color
                            }.configure {
                                $0.rowHeight = 8
                            })
                        
                        eventRow.append(CustomRowFormer<EventFeedCell>(instantiateType: .Nib(nibName: "EventFeedCell")) {
                            let user = event["organizer"] as! PFUser
                            $0.title.text = event["title"] as? String
                            $0.location.text = event["location"] as? String
                            let startDate = event["start"] as? NSDate
                            let endDate = event["end"] as? NSDate
                            let interval = endDate!.timeIntervalSinceDate(startDate!)
                            
                            $0.timeDay.text = "\(startDate!.shortTimeString) on \(startDate!.longDateString) for \((Int(interval) + 1)/60) minutes"
                            $0.organizer.text = "Organized By: \(user.valueForKey("fullname") as! String)"
                            $0.attendence.text = "\(event["confirmed"].count) Confirmed, \(event["maybe"].count) Maybe"
                            }.configure {
                                $0.rowHeight = UITableViewAutomaticDimension
                            }.onSelected {_ in
                                let detailVC = EventDetailViewController()
                                detailVC.event = event
                                detailVC.color = WESST_COLOR
                                self.navigationController?.pushViewController(detailVC, animated: true)
                            })
                        
                        
                        
                        //end creating rows
                        
                        eventsSection.append(rowFormer: eventRow[index])
                        eventsSection.append(rowFormer: eventDividerRow[index])
                        index += 1
                    }
                }
            } else {
                print("An error occured")
                print(error.debugDescription)
            }
            
            
            self.former.insertUpdate(sectionFormer: eventsSection.set(headerViewFormer: Utilities.createHeader("\(Profile.sharedInstance.user![PF_USER_FULLNAME] as! String) will be attending")), toSection: 1, rowAnimation: .Bottom)
            self.former.reload()
            
        }
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
