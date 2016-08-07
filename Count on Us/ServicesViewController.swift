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
        tableView.contentInset.top = 40
        
        self.searchBar.delegate = self
        
        title = "Service Discounts"
        
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
        let servicesQuery = PFQuery(className: PF_SERVICES_CLASS_NAME)
        servicesQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) in
            if error == nil {
                if results != nil {
                    for result in results! {
                        //print(result)
                        services.append(CustomRowFormer<PostCell>(instantiateType: .Nib(nibName: "PostCell")) {
                            $0.company.text = result[PF_BUSINESS_NAME] as? String
                            $0.company.font = .boldSystemFontOfSize(18)
                            $0.company.textColor = SAP_COLOR
                            
                            $0.website.text = result[PF_BUSINESS_INFO] as? String
                            $0.website.font = .boldSystemFontOfSize(15)
                    
                            let startTime = result[PF_BUSINESS_STARTTIME] as? Int
                            let endTime = result[PF_BUSINESS_ENDTIME] as? Int
                            let availability = self.getStringForTimes(startTime!, endTime: endTime!)
                            $0.deal.text = availability
                            
                            let dealDates = result[PF_BUSINESS_DEALDAY] as? [String]
                            let datesAbbrev = self.getDayAbbrevations(dealDates!)
                            $0.dealDates.text = datesAbbrev

                            }.configure {
                                $0.rowHeight = UITableViewAutomaticDimension
                            }
                            .onSelected { [weak self] _ in
                                let detailVC = BusinessDetailViewController()
                                detailVC.business = result
                                self!.navigationController?.pushViewController(detailVC, animated: true)
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
    
    func searchUsers(searchString: String) {
        var services = [CustomRowFormer<PostCell>]()
        let servicesQuery = PFQuery(className: PF_SERVICES_CLASS_NAME)
        servicesQuery.whereKey(PF_BUSINESS_LOWERCASE, containsString: searchString)
        servicesQuery.addAscendingOrder(PF_BUSINESS_LOWERCASE)
        servicesQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) in
            if error == nil {
                if results != nil {
                    for result in results! {
                        //print(result)
                        services.append(CustomRowFormer<PostCell>(instantiateType: .Nib(nibName: "PostCell")) {
                            $0.company.text = result[PF_BUSINESS_NAME] as? String
                            $0.company.font = .boldSystemFontOfSize(18)
                            $0.company.textColor = SAP_COLOR
                            
                            $0.website.text = result[PF_BUSINESS_INFO] as? String
                            $0.website.font = .boldSystemFontOfSize(15)
                            
                            let startTime = result[PF_BUSINESS_STARTTIME] as? Int
                            let endTime = result[PF_BUSINESS_ENDTIME] as? Int
                            let availability = self.getStringForTimes(startTime!, endTime: endTime!)
                            $0.deal.text = availability
                            
                            let dealDates = result[PF_BUSINESS_DEALDAY] as? [String]
                            let datesAbbrev = self.getDayAbbrevations(dealDates!)
                            $0.dealDates.text = datesAbbrev
                            //TODO: add color ?
                            }.configure {
                                $0.rowHeight = UITableViewAutomaticDimension
                            }
                            .onSelected { [weak self] _ in
                                let detailVC = BusinessDetailViewController()
                                detailVC.business = result
                                self!.navigationController?.pushViewController(detailVC, animated: true)
                            })
                    }
                    self.former.removeAll()
                    self.former.reload()
                    self.former.append(sectionFormer: SectionFormer(rowFormers: services))
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
            SVProgressHUD.showWithStatus("Loading Services")
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
        SVProgressHUD.showWithStatus("Loading Services")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            self.configure()
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                SVProgressHUD.dismiss()
            })
        })
        
    }


}
