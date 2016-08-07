//
//  ListViewController.swift
//  Count on Us
//
//  Created by Edward Zhou Muhua on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse
import Former
import SVProgressHUD

class ListViewController: FormViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var businesses: [PFObject]!
    var className: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.searchBar?.delegate = self
        title = "\(self.className) Discounts"
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 100)
        tableView.contentInset.top = 40
        
        SVProgressHUD.showWithStatus("Loading available \(self.className)...")
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
        else if days.count == 5 &&
            days.contains("Monday") &&
            days.contains("Tuesday") &&
            days.contains("Wednesday") &&
            days.contains("Thursday") &&
            days.contains("Friday") {
            return "Weekdays"
        } else if days.count == 2 &&
            days.contains("Saturday") &&
            days.contains("Sunday") {
            return "Weekends"
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
            for business in self.businesses! {
                //print(result)
                services.append(CustomRowFormer<PostCell>(instantiateType: .Nib(nibName: "PostCell")) {
                    $0.company.text = business[PF_BUSINESS_NAME] as? String
                    $0.company.font = .boldSystemFontOfSize(18)
                    $0.company.textColor = SAP_COLOR
                    
                    $0.website.text = business[PF_BUSINESS_INFO] as? String
                    $0.website.font = .boldSystemFontOfSize(15)
                    
                    let startTime = business[PF_BUSINESS_STARTTIME] as? Int
                    let endTime = business[PF_BUSINESS_ENDTIME] as? Int
                    let availability = self.getStringForTimes(startTime!, endTime: endTime!)
                    $0.deal.text = availability
                    
                    let dealDates = business[PF_BUSINESS_DEALDAY] as? [String]
                    let datesAbbrev = self.getDayAbbrevations(dealDates!)
                    $0.dealDates.text = datesAbbrev
                    
                    }.configure {
                        $0.rowHeight = UITableViewAutomaticDimension
                    }
                    .onSelected { [weak self] _ in
                        let detailVC = BusinessDetailViewController()
                        detailVC.business = business
                        self!.navigationController?.pushViewController(detailVC, animated: true)
                    })
            }
        
            self.former.append(sectionFormer: SectionFormer(rowFormers: services))
            self.former.reload()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBusinesses(searchString: String) -> [PFObject]? {
        var filteredBusinesses = [PFObject]()
        for business in self.businesses {
            if business[PF_BUSINESS_LOWERCASE].containsString(searchString) {
                filteredBusinesses.append(business)
            }
        }
        return filteredBusinesses
        
    }
    
    func searchUsers(searchString: String) {
        var services = [CustomRowFormer<PostCell>]()
        let filteredBusinesses = self.searchBusinesses(searchString)
        for business in filteredBusinesses! {
            //print(result)
            services.append(CustomRowFormer<PostCell>(instantiateType: .Nib(nibName: "PostCell")) {
                $0.company.text = business[PF_BUSINESS_NAME] as? String
                $0.company.font = .boldSystemFontOfSize(18)
                $0.company.textColor = SAP_COLOR
                
                $0.website.text = business[PF_BUSINESS_INFO] as? String
                $0.website.font = .boldSystemFontOfSize(15)
                
                let startTime = business[PF_BUSINESS_STARTTIME] as? Int
                let endTime = business[PF_BUSINESS_ENDTIME] as? Int
                let availability = self.getStringForTimes(startTime!, endTime: endTime!)
                $0.deal.text = availability
                
                let dealDates = business[PF_BUSINESS_DEALDAY] as? [String]
                let datesAbbrev = self.getDayAbbrevations(dealDates!)
                $0.dealDates.text = datesAbbrev
                //TODO: add color ?
                }.configure {
                    $0.rowHeight = UITableViewAutomaticDimension
                }
                .onSelected { [weak self] _ in
                    let detailVC = BusinessDetailViewController()
                    detailVC.business = business
                    self!.navigationController?.pushViewController(detailVC, animated: true)
                })
        }
        self.former.removeAll()
        self.former.reload()
        self.former.append(sectionFormer: SectionFormer(rowFormers: services))
        self.former.reload()
        
    }
    // MARK: - UISearchBar Delegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.searchUsers(searchText.lowercaseString)
        } else {
            self.former.removeAll()
            self.former.reload()
            SVProgressHUD.showWithStatus("Loading \(self.className)")
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
        self.former.reload()
        SVProgressHUD.showWithStatus("Loading \(self.className)")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            self.configure()
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                SVProgressHUD.dismiss()
            })
        })
        
    }
    
    
}
