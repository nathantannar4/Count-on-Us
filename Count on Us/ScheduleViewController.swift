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

class ScheduleViewController: UIViewController {
    
    let userData = UserData()
    let today = NSDate.today()
    
    var AttendingArray = [NSDate]()
    var InvitedArray = [NSDate]()
    
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
        calendarView.firstDayOfWeek = .Monday
        calendarView.allowsMultipleSelection = true
        
        
        
//        AttendingArray.append(NSDate())
//        InvitedArray.append(NSDate().dateByAddingDays(1))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        calendarView.scrollToDate(today)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        for attendingDate in AttendingArray {
            if attendingDate.isInSameDayAsDate(date) && attendingDate.isSameMonthAsDate(date) && attendingDate.isSameYearAsDate(date) {
                cell.configureCircleColor("Attending")
            }
        }
        for invitedDate in InvitedArray {
            if invitedDate.isInSameDayAsDate(date) && invitedDate.isSameMonthAsDate(date) && invitedDate.isSameYearAsDate(date) {
                cell.configureCircleColor("Invited")
            }
        }
        
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        let cell = (cell as! CellView)
        print(cell)
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
