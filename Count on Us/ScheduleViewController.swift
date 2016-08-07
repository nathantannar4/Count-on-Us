//
//  ScheduleViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SwiftDate
import RealmSwift
import Parse
import QuartzCore

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var acceptedLegendLabel: UILabel!
    @IBOutlet weak var tentativeLegendLabel: UILabel!
    
    let userData = UserData()
    let today = NSDate.today()
    
    var AttendingArray = [NSDate]()
    var InvitedArray = [NSDate]()
    
    var EventArray = [PFObject]()
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthNameLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule"
        
        // Configure Navbar
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        
        calendarView.registerCellViewXib(fileName: "CellView")
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        calendarView.firstDayOfWeek = .Sunday
        
        acceptedLegendLabel.layer.cornerRadius = 8
        acceptedLegendLabel.layer.masksToBounds = true
        tentativeLegendLabel.layer.cornerRadius = 8
        tentativeLegendLabel.layer.masksToBounds = true;
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.scrollToDate(today)
        AttendingArray.removeAll()
        InvitedArray.removeAll()
        EventArray.removeAll()
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configure(){
        let datesQuery = PFQuery(className: PF_EVENTS_CLASS_NAME)
        datesQuery.whereKey("inviteTo", containedIn: [PFUser.currentUser()!])
        datesQuery.includeKey("organizer")
        datesQuery.includeKey("business")
        datesQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) in
            if error == nil {
                if results != nil {
                    for result in results! {
                        let eventDate = result["start"] as? NSDate
                        if (result["confirmed"] as! [PFUser])
                            .map({user in user.objectId!})
                            .contains(PFUser.currentUser()!.objectId!) {
                            self.AttendingArray.append(eventDate!)
                            self.EventArray.append(result)
                        } else {
                            let eventDate = result["start"] as? NSDate
                            self.InvitedArray.append(eventDate!)
                            self.EventArray.append(result)
                        }
                    }
                    self.calendarView.reloadData()
                    
                }
            }
        })
    }

}

extension ScheduleViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate   {
    
    // Setting up manditory protocol method
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        // You can set your date using NSDate() or NSDateFormatter. Your choice.
        let firstDate = NSDate().dateBySubtractingMonths(3)
        let secondDate = NSDate().dateByAddingYears(1)
        let aCalendar = NSCalendar.currentCalendar() // Properly configure your calendar to your time zone here
        let numberOfRows = 6
        return (startDate: firstDate!, endDate: secondDate, numberOfRows: numberOfRows, calendar: aCalendar)
    }

    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        let cell = (cell as! CellView)
        cell.setupCellBeforeDisplay(cellState, date: date)
        
        cell.configureCircleColor("Blank")
        
        for invitedDate in InvitedArray {
            if invitedDate.isInSameDayAsDate(date) && invitedDate.isSameMonthAsDate(date) && invitedDate.isSameYearAsDate(date) {
                cell.configureCircleColor("Invited")
            }
        }
        
        for attendingDate in AttendingArray {
            if attendingDate.isInSameDayAsDate(date) && attendingDate.isSameMonthAsDate(date) && attendingDate.isSameYearAsDate(date) {
                cell.configureCircleColor("Attending")
            }
        }
        
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        var activeEvents = [PFObject]()
        for event in EventArray {
            let eventStart = event["start"] as! NSDate
            if eventStart.isInSameDayAsDate(date) && eventStart.isSameMonthAsDate(date) && eventStart.isSameYearAsDate(date) {
                activeEvents.append(event)
            }
        }
        print(activeEvents)
        
        if activeEvents.count == 0 {
            // Do Nothing
        } else if activeEvents.count == 1 {
            let detailVC = EventDetailViewController()
            let invite = activeEvents[0]
            detailVC.event = invite
            detailVC.business = invite["business"] as? PFObject
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            //Create the AlertController
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Which Event?", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            
            actionSheetController.addAction(cancelAction)
            print(activeEvents.count)
            for i in 0...activeEvents.count-1 {
                let single: UIAlertAction = UIAlertAction(title: ((activeEvents[i]).valueForKey("business") as? PFObject)!.valueForKey(PF_BUSINESS_NAME) as? String, style: .Default)
                { action -> Void in
                    let detailVC = EventDetailViewController()
                    let invite = activeEvents[i]
                    detailVC.event = invite
                    detailVC.business = invite["business"] as? PFObject
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
                actionSheetController.addAction(single)
            }
            
            
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
        
        
    }
    
    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        let cell = (cell as! CellView)
        cell.cellSelectionChanged(cellState)
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        let monthName = startDate.monthName
        let year = startDate.year
        monthNameLabel.text = monthName
        yearLabel.text = "\(year)"
    }
}
