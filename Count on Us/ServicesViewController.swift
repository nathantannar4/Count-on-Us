//
//  ServicesViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse
import Former
import SVProgressHUD

class ServicesViewController: FormViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Navbar
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        // Configure UI
        title = "Partner Services"
        tableView.contentInset.top = 40
        
        self.searchBar.delegate = self
        
        
        //configure UI
        title = "Services"
        
        SVProgressHUD.showWithStatus("Loading available Services...")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            self.configure()
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                SVProgressHUD.dismiss()
            })
        })
        
    }

    private func getDayAbbrevations(days: [String]) -> String {
        if days.count == 7 {
            return "Everyday"
        }
        
        var daysAbbrevs = [String]()
        for day in days {
            let index = day.startIndex.advancedBy(3)
            let dayAbbrev = day.substringToIndex(index)
            daysAbbrevs.append(dayAbbrev)
        }
        
        return daysAbbrevs.joinWithSeparator(",")
    }
    
    private func getStringForTimes(startTime: Int, endTime: Int) -> String {
        if startTime == 0 && endTime == 2400 {
            return "All Day"
        } else {
            return "From \(startTime)h to \(endTime)h"
        }
    }

    private func configure() {
        var services = [CustomRowFormer<PostCell>]()
        let servicesQuery = PFQuery(className: "Services")
        servicesQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) in
            if error == nil {
                if results != nil {
                    for result in results! {
                        print(result)
                        services.append(CustomRowFormer<PostCell>(instantiateType: .Nib(nibName: "PostCell")) {
                            $0.company.text = result["company"] as? String
                            $0.website.text = result["info"] as? String
                        
                            let startTime = result["startTime"] as? Int
                            let endTime = result["endTime"] as? Int
                            let availability = self.getStringForTimes(startTime!, endTime: endTime!)
                            $0.deal.text = availability
                            
                            let dealDates = result["dealDay"] as? [String]
                            let datesAbbrev = self.getDayAbbrevations(dealDates!)
                            $0.dealDates.text = datesAbbrev
                            //TODO: add color ? 
                            }.configure {
                                $0.rowHeight = UITableViewAutomaticDimension
                            }
                            .onSelected { [weak self] _ in
                                //TODO: navigate to service profile views
                            })
                    }
                    
                    self.former.append(sectionFormer: SectionFormer(rowFormers: services))
                    self.former.reload()
                }
            }
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
