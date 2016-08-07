//
//  ColleaguesViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//


import UIKit
import Parse
import Former
import SVProgressHUD

class ColleaguesViewController: FormViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI
        title = "SAP colleagues"
        tableView.contentInset.top = 40
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        
        self.searchBar.delegate = self
        
        // Populate table
        SVProgressHUD.showWithStatus("Loading Colleagues")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            self.configure()
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                SVProgressHUD.dismiss()
            })
        })
        
    }
    
    // MARK: Private
    
    private lazy var zeroRow: LabelRowFormer<ImageCell> = {
        LabelRowFormer<ImageCell>(instantiateType: .Nib(nibName: "ImageCell")) {_ in
            }.configure {
                $0.rowHeight = 0
        }
    }()
    
    func searchUsers(searchLower: String) {
        var colleagues = [LabelRowFormer<ProfileImageDetailCell>]()
        let userQuery = PFUser.query()
        userQuery?.whereKey(PF_USER_FULLNAME_LOWER, containsString: searchLower)
        userQuery?.addAscendingOrder(PF_USER_FULLNAME)
        userQuery?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error: NSError?) in
            if error == nil {
                if users != nil {
                    for user in users! {
                        colleagues.append(LabelRowFormer<ProfileImageDetailCell>(instantiateType: .Nib(nibName: "ProfileImageDetailCell")) {
                            $0.accessoryType = .DisclosureIndicator
                            $0.iconView.backgroundColor = SAP_COLOR
                            $0.iconView.layer.borderWidth = 2
                            $0.iconView.layer.borderColor = SAP_COLOR.CGColor
                            let userImageFile = user[PF_USER_PICTURE] as? PFFile
                            if userImageFile != nil {
                                do {
                                    $0.iconView.image = UIImage(data: try userImageFile!.getData())
                                } catch _ {}
                            }
                            $0.titleLabel.textColor = UIColor.blackColor()
                            $0.detailLabel.text = user[PF_USER_TITLE] as? String
                            $0.detailLabel.textColor = UIColor.grayColor()
                            }.configure {
                                $0.text = user[PF_USER_FULLNAME] as? String
                                $0.rowHeight = 60
                            }.onSelected { [weak self] _ in
                                self?.former.deselect(true)
                                let profileVC = PublicProfileViewController()
                                profileVC.user = user
                                self?.navigationController?.pushViewController(profileVC, animated: true)
                            })
                    }
                    self.former.removeAll()
                    self.former.reload()
                    self.former.append(sectionFormer: SectionFormer(rowFormers: colleagues))
                    self.former.reload()
                }
            }
        })
        
    }
    
    // MARK: - UISearchBar Delegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.searchUsers(searchText.lowercaseString)
        } else {
            former.removeAll()
            former.reload()
            SVProgressHUD.showWithStatus("Loading colleagues")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
                self.configure()
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    SVProgressHUD.dismiss()
                })
            })
            
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBarCancelled()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelled() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        self.former.removeAll()
        former.reload()
        SVProgressHUD.showWithStatus("Loading Colleagues")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            self.configure()
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                SVProgressHUD.dismiss()
            })
        })
        
    }
    
    
    private func configure() {
        
        var colleagues = [LabelRowFormer<ProfileImageDetailCell>]()
        
        let userQuery = PFUser.query()
        userQuery?.addAscendingOrder(PF_USER_FULLNAME)
        userQuery?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error: NSError?) in
            if error == nil {
                if users != nil {
                    for user in users! {
                        colleagues.append(LabelRowFormer<ProfileImageDetailCell>(instantiateType: .Nib(nibName: "ProfileImageDetailCell")) {
                            $0.accessoryType = .DisclosureIndicator
                            $0.iconView.backgroundColor = SAP_COLOR
                            $0.iconView.layer.borderWidth = 2
                            $0.iconView.layer.borderColor = SAP_COLOR.CGColor
                            let userImageFile = user[PF_USER_PICTURE] as? PFFile
                            if userImageFile != nil {
                                do {
                                    $0.iconView.image = UIImage(data: try userImageFile!.getData())
                                } catch _ {}
                            }
                            $0.titleLabel.textColor = UIColor.blackColor()
                            $0.detailLabel.text = user[PF_USER_TITLE] as? String
                            $0.detailLabel.textColor = UIColor.grayColor()
                            }.configure {
                                $0.text = user[PF_USER_FULLNAME] as? String
                                $0.rowHeight = 60
                            }.onSelected { [weak self] _ in
                                self?.former.deselect(true)
                                let profileVC = PublicProfileViewController()
                                profileVC.user = user
                                self?.navigationController?.pushViewController(profileVC, animated: true)
                            })
                    }
                    
                    self.former.append(sectionFormer: SectionFormer(rowFormers: colleagues))
                    self.former.reload()
                }
            }
        })
    }
    
}
