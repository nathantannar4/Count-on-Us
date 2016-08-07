//
//  StatsViewController.swift
//  Count on Us
//
//  Created by Tannar, Nathan on 2016-08-07.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Parse

class StatsViewController: UIViewController, PNChartDelegate {
    
    var business: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(business)
        
        // Do any additional setup after loading the view.
        let ChartLabel:UILabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 40))
        
        ChartLabel.textColor = SAP_COLOR
        ChartLabel.font = UIFont(name: "Avenir-Medium", size:23.0)
        ChartLabel.textAlignment = NSTextAlignment.Center
        
        ChartLabel.text = "Visits Per Day"
        
        let lineChart: PNLineChart = PNLineChart(frame: CGRectMake(0, 40, self.view.frame.width, 400.0))
        lineChart.yLabelFormat = "%1.1f"
        lineChart.showLabel = true
        lineChart.backgroundColor = UIColor.clearColor()
        
        lineChart.xLabels = ["TEST", "TEST2"]
        lineChart.showCoordinateAxis = true
        lineChart.delegate = self
        
        // Line Chart Nr.1
        var data01Array: [CGFloat] = business["dayStatsCount"] as! [CGFloat]
        let data01:PNLineChartData = PNLineChartData()
        data01.color = SAP_COLOR
        data01.itemCount = data01Array.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            let yValue:CGFloat = data01Array[index]
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        lineChart.chartData = [data01]
        lineChart.strokeChart()
        
        self.view.addSubview(lineChart)
        self.view.addSubview(ChartLabel)
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Statistics"

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, keyPointIndex: Int)
    {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex) and point index is \(keyPointIndex)")
    }
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int)
    {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex)")
    }
    
    func userClickedOnBarChartIndex(barIndex: Int)
    {
        print("Click  on bar \(barIndex)")
    }
    
}

