//
//  BusinessDetailViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse
import Former
import MapKit
import CoreLocation
import JSQWebViewController

class BusinessDetailViewController: FormViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var business: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = business[PF_BUSINESS_NAME] as? String
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 50
        
        configure()
    }
    
    private func configure() {
        
        let mapRow = CustomRowFormer<MapCell>(instantiateType: .Nib(nibName: "MapCell")) {
            let anotation = MKPointAnnotation()
            anotation.coordinate = CLLocation(latitude: self.business[PF_BUSINESS_LAT] as! Double, longitude: self.business[PF_BUSINESS_LONG] as! Double).coordinate
            anotation.title = self.business[PF_BUSINESS_NAME] as? String
            anotation.subtitle = self.business[PF_BUSINESS_INFO] as? String
            $0.mapView.addAnnotation(anotation)
            let latitude = self.business[PF_BUSINESS_LAT] as! Double
            let longitude = self.business[PF_BUSINESS_LONG] as! Double
            let latDelta:CLLocationDegrees = 0.001
            let lonDelta:CLLocationDegrees = 0.001
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            $0.mapView.setRegion(region, animated: true)
            $0.selectionStyle = .None
            }.configure {
                $0.rowHeight = 200
            }.onSelected { _ in
                self.former.deselect(true)
                
        }
        let phoneRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Nib(nibName: "DynamicHeightCell")) {
            $0.title = "Phone"
            $0.body = self.business[PF_BUSINESS_PHONE] as? String
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.titleLabel.textColor = SAP_COLOR
            $0.bodyLabel.font = .systemFontOfSize(15)
            $0.date = ""
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
            }.onSelected { _ in
                self.former.deselect(true)
                var phoneNumber = self.business[PF_BUSINESS_PHONE] as! String
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("(", withString: "")
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(")", withString: "")
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("-", withString: "")
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("+", withString: "")
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                if let url = NSURL(string: "tel://\(phoneNumber)") {
                    let actionSheetController: UIAlertController = UIAlertController(title: "Would you like to call", message: self.business[PF_BUSINESS_PHONE] as? String, preferredStyle: .ActionSheet)
                    actionSheetController.view.tintColor = SAP_COLOR
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                        //Just dismiss the action sheet
                    }
                    actionSheetController.addAction(cancelAction)
                    let single: UIAlertAction = UIAlertAction(title: "Yes", style: .Default)
                    { action -> Void in
                        UIApplication.sharedApplication().openURL(url)
                    }
                    actionSheetController.addAction(single)
                    
                    //Present the AlertController
                    self.presentViewController(actionSheetController, animated: true, completion: nil)
                }

        }
        let infoRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Nib(nibName: "DynamicHeightCell")) {
            $0.title = "SAP Discount"
            $0.body = self.business[PF_BUSINESS_INFO] as? String
            let moreInfo = self.business[PF_BUSINESS_MORE_INFO] as? String
            if moreInfo != nil && moreInfo != "" {
                $0.body = $0.body?.stringByAppendingString("\n\n\(moreInfo!)")
            }
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.titleLabel.textColor = SAP_COLOR
            $0.bodyLabel.font = .systemFontOfSize(15)
            $0.date = ""
            $0.selectionStyle = .None
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
            }.onSelected { _ in
                self.former.deselect(true)
        }
        let whenOffered = CustomRowFormer<DynamicHeightCell>(instantiateType: .Nib(nibName: "DynamicHeightCell")) {
            $0.title = "Discount Offered"
            let discountDays = self.business[PF_BUSINESS_DEALDAY] as! [String]
            var days = ""
            for day in discountDays {
                days = days.stringByAppendingString(day) + ", "
            }
            days = days.stringByPaddingToLength(days.characters.count - 2, withString: days, startingAtIndex: 0)
            $0.body = days
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.titleLabel.textColor = SAP_COLOR
            $0.bodyLabel.font = .systemFontOfSize(15)
            let startTime = self.business[PF_BUSINESS_STARTTIME] as! Int
            let endTime = self.business[PF_BUSINESS_ENDTIME] as! Int
            if endTime - startTime == 2400 {
                $0.date = "All Day"
            } else {
                $0.date = "\(startTime) - \(endTime)"
            }
            $0.selectionStyle = .None
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
            }.onSelected { _ in
                self.former.deselect(true)
        }
        let urlRow = LabelRowFormer<FormLabelCell>()
            .configure {
                $0.text = "Website"
                $0.subText = self.business[PF_BUSINESS_WEBSITE] as? String
            }.onSelected { [weak self] _ in
                self?.former.deselect(true)
                let controller = WebViewController(url: NSURL(string: self!.business[PF_BUSINESS_WEBSITE] as! String)!)
                let nav = UINavigationController(rootViewController: controller)
                nav.navigationBar.barTintColor = SAP_COLOR
                self!.presentViewController(nav, animated: true, completion: nil)
        }
        let reviewRow = LabelRowFormer<FormLabelCell>()
            .configure {
                $0.text = "Yelp"
                $0.subText = self.business[PF_BUSINESS_REVIEW] as? String
            }.onSelected { [weak self] _ in
                self?.former.deselect(true)
                let controller = WebViewController(url: NSURL(string: self!.business[PF_BUSINESS_REVIEW] as! String)!)
                let nav = UINavigationController(rootViewController: controller)
                nav.navigationBar.barTintColor = SAP_COLOR
                self!.presentViewController(nav, animated: true, completion: nil)
        }

        
        
        self.former.append(sectionFormer: SectionFormer(rowFormer: mapRow, infoRow, whenOffered, phoneRow, urlRow, reviewRow))
        self.former.reload()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}
