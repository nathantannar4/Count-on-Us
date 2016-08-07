//
//  CellView.swift
//  Count on Us
//
//  Created by Austin Chen on 2016-08-06.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import JTAppleCalendar

class CellView: JTAppleDayCellView {
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var circleView: UIImageView!
    
    var blackColor = UIColor.blackColor()
    var greyColor = UIColor.grayColor()
    var whiteColor = UIColor.whiteColor()
    
    var attendingEvent = SAP_COLOR
    var invitedEvent = SAP_COLOR.colorWithAlphaComponent(0.5)
    var blankEvent = SAP_COLOR.colorWithAlphaComponent(0)
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        // Setup Cell text
        dateLabel.text =  cellState.text
        
        // Setup text color
        configureTextColor(cellState)
        circleView.layer.cornerRadius = CGRectGetHeight(dateLabel.bounds) / 2
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == .ThisMonth {
            dateLabel.textColor = blackColor
        } else {
            dateLabel.textColor = greyColor
        }
    }
    
    func configureCircleColor(eventState: String) {
        if eventState == "Attending" {
            circleView.backgroundColor = attendingEvent
        } else if eventState == "Invited" {
            circleView.backgroundColor = invitedEvent
        } else {
            circleView.backgroundColor = blankEvent
        }
    }
    
    func cellSelectionChanged(cellState: CellState) {
        
    }
    
}