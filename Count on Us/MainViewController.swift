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
                let agrume = Agrume(image: cell.cell.displayImage.image!)
                    agrume.showFrom(self)
            })
    }()
    
    private func configure() {
        
        self.former.append(sectionFormer: SectionFormer(rowFormer: onlyImageRow))
        self.former.reload()
        
        var invites = [LabelRowFormer<ProfileImageDetailCell>]()
        
        let query = PFUser.query()
        query?.whereKey("sentTo", equalTo: PFUser.currentUser()!)
        query?.addAscendingOrder(PF_CREATEDAT)
        query?.includeKey("sentFrom")
        query?.findObjectsInBackgroundWithBlock({ (invitations: [PFObject]?, error: NSError?) in
            if error == nil {
                if invitations != nil {
                    for invite in invitations! {
                        invites.append(LabelRowFormer<ProfileImageDetailCell>(instantiateType: .Nib(nibName: "ProfileImageDetailCell")) {
                            $0.accessoryType = .DisclosureIndicator
                            $0.iconView.backgroundColor = SAP_COLOR
                            $0.iconView.layer.borderWidth = 2
                            $0.iconView.layer.borderColor = SAP_COLOR.CGColor
                            /*
                            let userImageFile = user[PF_USER_PICTURE] as? PFFile
                            if userImageFile != nil {
                                do {
                                    $0.iconView.image = UIImage(data: try userImageFile!.getData())
                                } catch _ {}
                            }
 */
                            $0.titleLabel.textColor = UIColor.blackColor()
                            $0.detailLabel.text = "Detail"
                            $0.detailLabel.textColor = UIColor.grayColor()
                            }.configure {
                                $0.text = "User"
                                $0.rowHeight = 60
                            }.onSelected { [weak self] _ in
                                self?.former.deselect(true)
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

