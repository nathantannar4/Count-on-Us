//
//  JTAppleCalendarView.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

let cellReuseIdentifier = "JTDayCell"

let NUMBER_OF_DAYS_IN_WEEK = 7

let MAX_NUMBER_OF_DAYS_IN_WEEK = 7                              // Should not be changed
let MIN_NUMBER_OF_DAYS_IN_WEEK = MAX_NUMBER_OF_DAYS_IN_WEEK     // Should not be changed
let MAX_NUMBER_OF_ROWS_PER_MONTH = 6                            // Should not be changed
let MIN_NUMBER_OF_ROWS_PER_MONTH = 1                            // Should not be changed

let FIRST_DAY_INDEX = 0
let OFFSET_CALC = 2
let NUMBER_OF_DAYS_INDEX = 1
let DATE_SELECTED_INDEX = 2
let TOTAL_DAYS_IN_MONTH = 3
let DATE_BOUNDRY = 4

/// Describes which month the cell belongs to
/// - ThisMonth: Cell belongs to the current month
/// - PreviousMonthWithinBoundary: Cell belongs to the previous month. Previous month is included in the date boundary you have set in your delegate
/// - PreviousMonthOutsideBoundary: Cell belongs to the previous month. Previous month is not included in the date boundary you have set in your delegate
/// - FollowingMonthWithinBoundary: Cell belongs to the following month. Following month is included in the date boundary you have set in your delegate
/// - FollowingMonthOutsideBoundary: Cell belongs to the following month. Following month is not included in the date boundary you have set in your delegate
///
/// You can use these cell states to configure how you want your date cells to look. Eg. you can have the colors belonging to the month be in color black, while the colors of previous months be in color gray.
public struct CellState {
    /// Describes which month owns the date
    public enum DateOwner: Int {
        /// Describes which month owns the date
        case ThisMonth = 0, PreviousMonthWithinBoundary, PreviousMonthOutsideBoundary, FollowingMonthWithinBoundary, FollowingMonthOutsideBoundary
    }
    /// returns true if a cell is selected
    public let isSelected: Bool
    /// returns the date as a string
    public let text: String
    /// returns the a description of which month owns the date
    public let dateBelongsTo: DateOwner
    /// returns the date
    public let date: NSDate
    /// returns the day
    public let day: DaysOfWeek
    /// returns the row in which the date cell appears visually
    public let row: ()->Int
    /// returns the column in which the date cell appears visually
    public let column: ()->Int
    /// returns the section the date cell belongs to
    public let dateSection: ()->(startDate: NSDate, endDate: NSDate)
    /// returns the cell frame. Useful if you wish to display something at the cell's frame/position
    public var cell: ()->JTAppleDayCell?
}

/// Days of the week. By setting you calandar's first day of week, you can change which day is the first for the week. Sunday is by default.
public enum DaysOfWeek: Int {
    /// Days of the week.
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

/// An instance of JTAppleCalendarView (or simply, a calendar view) is a means for displaying and interacting with a gridstyle layout of date-cells
public class JTAppleCalendarView: UIView {
    /// The amount of buffer space before the first row of date-cells
    public var bufferTop: CGFloat    = 0.0
    /// The amount of buffer space after the last row of date-cells
    public var bufferBottom: CGFloat = 0.0
    /// Configures the size of your date cells
    public var itemSize: CGFloat?
    
    /// Enables and disables animations when scrolling to and from date-cells
    public var animationsEnabled = true
    /// The scroll direction of the sections in JTAppleCalendar.
    public var direction : UICollectionViewScrollDirection = .Horizontal {
        didSet {
            if oldValue == direction { return }
            let layout = generateNewLayout()
            calendarView.collectionViewLayout = layout
        }
    }
    /// Enables/Disables multiple selection on JTAppleCalendar
    public var allowsMultipleSelection: Bool = false {
        didSet {
            self.calendarView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    /// First day of the week value for JTApleCalendar. You can set this to anyday. After changing this value you must reload your calendar view to show the change.
    public var firstDayOfWeek = DaysOfWeek.Sunday {
        didSet {
            if firstDayOfWeek != oldValue { layoutNeedsUpdating = true }
        }
    }
    /// When enabled the date snaps to the edges of the calendar view when a user scrolls
    public var cellSnapsToEdge = true
    var triggerScrollToDateDelegate: Bool? = true
    
    
    // Keeps track of item size for a section. This is an optimization
    var scrollInProgress = false
    private var layoutNeedsUpdating = false
    
    /// The object that acts as the data source of the calendar view.
    weak public var dataSource : JTAppleCalendarViewDataSource? {
        didSet {
            monthInfo = setupMonthInfoDataForStartAndEndDate()
            updateLayoutItemSize(calendarView.collectionViewLayout as! JTAppleCalendarLayout)
            reloadData(checkDelegateDataSource: false)
        }
    }
    /// The object that acts as the delegate of the calendar view.
    weak public var delegate: JTAppleCalendarViewDelegate?

    var dateComponents = NSDateComponents()
    var delayedExecutionClosure: [(()->Void)] = []
    var lastOrientation: UIInterfaceOrientation?
    
    var currentSectionPage: Int {
        return (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).sectionFromRectOffset(calendarView.contentOffset)
    }
  
    var startDateCache: NSDate {
        get { return cachedConfiguration.startDate }
    }
    
    var endDateCache: NSDate {
        get { return cachedConfiguration.endDate }
    }
    
    var calendar: NSCalendar {
        get { return cachedConfiguration.calendar }
    }
    
    lazy var cachedConfiguration: (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) = {
        [weak self] in
        
        guard let  config = self!.dataSource?.configureCalendar(self!) else {
            assert(false, "DataSource is not set")
            return (startDate: NSDate(), endDate: NSDate(), 0, NSCalendar(calendarIdentifier: "nil")!)
        }
        
        return (startDate: config.startDate, endDate: config.endDate, numberOfRows: config.numberOfRows, calendar: config.calendar)
        }()
    
    // Set the start of the month
    lazy var startOfMonthCache: NSDate = {
        [weak self] in
        if let startDate = NSDate.startOfMonthForDate(self!.startDateCache, usingCalendar: self!.calendar) { return startDate }
        assert(false, "Error: StartDate was not correctly generated for start of month. current date was used: \(NSDate())")
        return NSDate()
        }()
    
    // Set the end of month
    lazy var endOfMonthCache: NSDate = {
        [weak self] in
        if let endDate = NSDate.endOfMonthForDate(self!.endDateCache, usingCalendar: self!.calendar) { return endDate }
        assert(false, "Error: Date was not correctly generated for end of month. current date was used: \(NSDate())")
        return NSDate()
        }()
    
    
    var theSelectedIndexPaths: [NSIndexPath] = []
    var theSelectedDates:      [NSDate]      = []
    
    /// Returns all selected dates
    public var selectedDates: [NSDate] {
        get {
            // Array may contain duplicate dates in case where out-dates are selected. So clean it up here
            return Array(Set(theSelectedDates)).sort()
        }
    }
    
    lazy var monthInfo : [[Int]] = {
        [weak self] in
        let newMonthInfo = self!.setupMonthInfoDataForStartAndEndDate()
        return newMonthInfo
        }()
    
    var numberOfMonths: Int = 0
    var numberOfSectionsPerMonth: Int = 0
    var numberOfItemsPerSection: Int {return MAX_NUMBER_OF_DAYS_IN_WEEK * cachedConfiguration.numberOfRows}
    
    /// Cell inset padding for the x and y axis of every date-cell on the calendar view.
    public var cellInset: CGPoint = CGPoint(x: 3, y: 3)
    var cellViewSource: JTAppleCalendarViewSource!
    var registeredHeaderViews: [JTAppleCalendarViewSource] = []
    
    /// Enable or disable paging when the calendar view is scrolled
    public var pagingEnabled: Bool = true {
        didSet { calendarView.pagingEnabled = pagingEnabled }
    }
    
    
    /// Enable or disable swipe scrolling of the calendar with this variable
    public var scrollEnabled: Bool = true {
        didSet { calendarView.scrollEnabled = scrollEnabled }
    }
    
    /// This is only applicable when calendar view paging is not enabled. Use this variable to decelerate the scroll movement to make it more 'sticky' or more fluid scrolling
    public var scrollResistance: CGFloat = 0.75
    
    lazy var calendarView : UICollectionView = {
        
        let layout = JTAppleCalendarLayout(withDelegate: self)
        layout.scrollDirection = self.direction
        
        let cv = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.pagingEnabled = true
        cv.backgroundColor = UIColor.clearColor()
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.allowsMultipleSelection = false
        return cv
    }()
    
    private func updateLayoutItemSize (layout: JTAppleCalendarLayoutProtocol) {
        if dataSource == nil { return } // If the delegate is not set yet, then return
        // Default Item height
        var height: CGFloat = (self.calendarView.bounds.size.height - layout.headerReferenceSize.height) / CGFloat(cachedConfiguration.numberOfRows)
        // Default Item width
        var width: CGFloat = self.calendarView.bounds.size.width / CGFloat(MAX_NUMBER_OF_DAYS_IN_WEEK)

        if let userSetItemSize = self.itemSize {
            if direction == .Vertical { height = userSetItemSize }
            if direction == .Horizontal { width = userSetItemSize }
        }

        layout.itemSize = CGSize(width: width, height: height)
    }
    
    /// The frame rectangle which defines the view's location and size in its superview coordinate system.
    override public var frame: CGRect {
        didSet {
            calendarView.frame = CGRect(x:0.0, y:/*bufferTop*/0.0, width: self.frame.size.width, height:self.frame.size.height/* - bufferBottom*/)
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            if orientation == .Unknown { return }
            if lastOrientation != orientation {
                calendarView.collectionViewLayout.invalidateLayout()
                let layout = calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol
                layout.clearCache()   
                lastOrientation = orientation
                updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
                if delegate != nil { reloadData() }
            } else {
                updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override public func awakeFromNib() { self.initialSetup() }
    
    /// Lays out subviews.
    override public func layoutSubviews() { self.frame = super.frame }
    
    // MARK: Setup
    func initialSetup() {
        self.clipsToBounds = true
        self.calendarView.registerClass(JTAppleDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        self.addSubview(self.calendarView)
    }
    
    func restoreSelectionStateForCellAtIndexPath(indexPath: NSIndexPath) {
        if theSelectedIndexPaths.contains(indexPath) {
            calendarView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    func dateFromSection(section: Int) -> (startDate: NSDate, endDate: NSDate)? {
        if monthInfo.count < 1 { return nil }
        
        let monthData = monthInfo[section]
        let itemLength = monthData[NUMBER_OF_DAYS_INDEX]
        let fdIndex = monthData[FIRST_DAY_INDEX]
        let startIndex = NSIndexPath(forItem: fdIndex, inSection: section)
        let endIndex = NSIndexPath(forItem: fdIndex + itemLength - 1, inSection: section)
        
        if let theStartDate = dateFromPath(startIndex), theEndDate = dateFromPath(endIndex) {
            return (theStartDate, theEndDate)
        }
        return nil
    }
    
    func calendarOffsetIsAlreadyAtScrollPosition(forIndexPath indexPath:NSIndexPath) -> Bool? {
        var retval: Bool?
        
        // If the scroll is set to animate, and the target content offset is already on the screen, then the didFinishScrollingAnimation
        // delegate will not get called. Once animation is on let's force a scroll so the delegate MUST get caalled
        if let attributes = self.calendarView.layoutAttributesForItemAtIndexPath(indexPath) {
            let origin = attributes.frame.origin
            let offset = direction == .Horizontal ? origin.x : origin.y
            if  self.calendarView.contentOffset.x == offset || (self.pagingEnabled && (indexPath.section ==  currentSectionPage)) {
                retval = true
            } else {
                retval = false
            }
        }
        return retval
    }
    
    func calendarOffsetIsAlreadyAtScrollPosition(forOffset offset:CGPoint) -> Bool? {
        var retval: Bool?
        
        // If the scroll is set to animate, and the target content offset is already on the screen, then the didFinishScrollingAnimation
        // delegate will not get called. Once animation is on let's force a scroll so the delegate MUST get caalled
        
        let theOffset = direction == .Horizontal ? offset.x : offset.y
        let divValue = direction == .Horizontal ? calendarView.frame.width : calendarView.frame.height
        let sectionForOffset = Int(theOffset / divValue)
        let calendarCurrentOffset = direction == .Horizontal ? calendarView.contentOffset.x : calendarView.contentOffset.y
        if
            calendarCurrentOffset == theOffset ||
                (self.pagingEnabled && (sectionForOffset ==  currentSectionPage)){
            retval = true
        } else {
            retval = false
        }
        return retval
    }
    
    func scrollToHeaderInSection(section:Int, triggerScrollToDateDelegate: Bool = false, withAnimation animation: Bool = true, completionHandler: (()->Void)? = nil)  {
        if registeredHeaderViews.count < 1 { return }
        
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        calendarView.layoutIfNeeded()
        if let attributes =  calendarView.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) {
            if let validHandler = completionHandler {
                delayedExecutionClosure.append(validHandler)
            }
            
            let topOfHeader = CGPointMake(attributes.frame.origin.x, attributes.frame.origin.y)
            self.scrollInProgress = true
            delayRunOnMainThread(0.0, closure: {
                self.calendarView.setContentOffset(topOfHeader, animated:animation)
                if  !animation {
                    self.scrollViewDidEndScrollingAnimation(self.calendarView)
                    self.scrollInProgress = false
                } else {
                    // If the scroll is set to animate, and the target content offset is already on the screen, then the didFinishScrollingAnimation
                    // delegate will not get called. Once animation is on let's force a scroll so the delegate MUST get caalled
                    if let check = self.calendarOffsetIsAlreadyAtScrollPosition(forOffset: topOfHeader) where check == true {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                        self.scrollInProgress = false
                    }
                }
            })
        }
    }
        
    func reloadData(checkDelegateDataSource check: Bool, withAnchorDate anchorDate: NSDate? = nil, withAnimation animation: Bool = false, completionHandler:(()->Void)? = nil) {
        // Reload the datasource
        if check { reloadDelegateDataSource() }
        var layoutWasUpdated: Bool?
        if layoutNeedsUpdating {
            self.configureChangeOfRows()
            self.layoutNeedsUpdating = false
            layoutWasUpdated = true
        }
        // Reload the data
        self.calendarView.reloadData()
        
        // Restore the selected index paths
        for indexPath in theSelectedIndexPaths { restoreSelectionStateForCellAtIndexPath(indexPath) }
        
        delayRunOnMainThread(0.0) {
            let scrollToDate = {(date: NSDate) -> Void in
                if self.registeredHeaderViews.count < 1 {
                    self.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: animation, completionHandler: completionHandler)
                } else {
                    self.scrollToHeaderForDate(date, triggerScrollToDateDelegate: false, withAnimation: animation, completionHandler: completionHandler)
                }
            }
            if let validAnchorDate = anchorDate { // If we have a valid anchor date, this means we want to scroll
                // This scroll should happen after the reload above
                scrollToDate(validAnchorDate)
            } else {
                if layoutWasUpdated == true {
                    // This is a scroll done after a layout reset and dev didnt set an anchor date. If a scroll is in progress, then cancel this one and
                    // allow it to take precedent
                    if !self.scrollInProgress {
                        scrollToDate(self.startOfMonthCache)
                    } else {
                        if let validCompletionHandler = completionHandler { self.delayedExecutionClosure.append(validCompletionHandler) }
                    }
                } else {
                    if let validCompletionHandler = completionHandler {
                        if self.scrollInProgress {
                            self.delayedExecutionClosure.append(validCompletionHandler)
                        } else {
                            validCompletionHandler()
                        }
                    }
                }
            }
        }
    }
    
    func executeDelayedTasks() {
        let tasksToExecute = delayedExecutionClosure
        for aTaskToExecute in tasksToExecute { aTaskToExecute() }
        delayedExecutionClosure.removeAll()
    }
    
    private func reloadDelegateDataSource() {
        if let
            newDateBoundary = dataSource?.configureCalendar(self) {
            // Jt101 do a check in each var to see if user has bad star/end dates
            let newStartOfMonth = NSDate.startOfMonthForDate(newDateBoundary.startDate, usingCalendar: cachedConfiguration.calendar)
            let newEndOfMonth = NSDate.endOfMonthForDate(newDateBoundary.startDate, usingCalendar: cachedConfiguration.calendar)
            let oldStartOfMonth = NSDate.startOfMonthForDate(cachedConfiguration.startDate, usingCalendar: cachedConfiguration.calendar)
            let oldEndOfMonth = NSDate.endOfMonthForDate(cachedConfiguration.startDate, usingCalendar: cachedConfiguration.calendar)

            
            if
                newStartOfMonth != oldStartOfMonth ||
                newEndOfMonth != oldEndOfMonth ||
                newDateBoundary.calendar != cachedConfiguration.calendar ||
                newDateBoundary.numberOfRows != cachedConfiguration.numberOfRows {
                    layoutNeedsUpdating = true
            }
        }
    }
    
    func configureChangeOfRows() {
        let layout = calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol
        layout.clearCache()
        monthInfo = setupMonthInfoDataForStartAndEndDate()
        
        // Only remove the selected dates and paths if the new layout does nto contain the date
        if pathsFromDates(theSelectedDates).count != theSelectedIndexPaths.count {
            theSelectedDates.removeAll()
            theSelectedIndexPaths.removeAll()
        }

        
    }
    
    func calendarViewHeaderSizeForSection(section: Int) -> CGSize {
        var retval = CGSizeZero
        if registeredHeaderViews.count > 0 {
            if let date = dateFromSection(section), size = delegate?.calendar(self, sectionHeaderSizeForDate: date){ retval = size }
        }
        return retval
    }
    
    func indexPathOfdateCellCounterPart(date: NSDate, indexPath: NSIndexPath, dateOwner: CellState.DateOwner) -> NSIndexPath? {
        var retval: NSIndexPath?
        if dateOwner != .ThisMonth { // If the cell is anything but this month, then the cell belongs to either a previous of following month
            // Get the indexPath of the counterpartCell
            let counterPathIndex = pathsFromDates([date])
            if counterPathIndex.count > 0 {
                retval = counterPathIndex[0]
            }
        } else { // If the date does belong to this month, then lets find out if it has a counterpart date
            if date >= startOfMonthCache && date <= endOfMonthCache {
                let dayIndex = calendar.components(.Day, fromDate: date).day
                if case 1...13 = dayIndex  { // then check the previous month
                    // get the index path of the last day of the previous month
                    
                    guard let prevMonth = calendar.dateByAddingUnit(.Month, value: -1, toDate: date, options: []) where prevMonth >= startOfMonthCache && prevMonth <= endOfMonthCache else {
                        return retval
                    }
                    
                    guard let lastDayOfPrevMonth = NSDate.endOfMonthForDate(prevMonth, usingCalendar: calendar) else {
                        print("Error generating date in indexPathOfdateCellCounterPart(). Contact the developer on github")
                        return retval
                    }
                    let indexPathOfLastDayOfPreviousMonth = pathsFromDates([lastDayOfPrevMonth])
                    if indexPathOfLastDayOfPreviousMonth.count > 0 {
                        let lastDayIndex = indexPathOfLastDayOfPreviousMonth[0].item
                        
                        let indexPathItemToBeFound = lastDayIndex + dayIndex
                        if indexPathItemToBeFound < 42 { // then it is valid
                            retval = NSIndexPath(forItem: indexPathItemToBeFound, inSection: indexPathOfLastDayOfPreviousMonth[0].section)
                        }
                    } else {
                        print("out of range error in indexPathOfdateCellCounterPart() upper. This should not happen. Contact developer on github")
                    }
                } else if case 26...31 = dayIndex  { // check the following month
                    guard let followingMonth = calendar.dateByAddingUnit(.Month, value: 1, toDate: date, options: []) where followingMonth >= startOfMonthCache && followingMonth <= endOfMonthCache else {
                        return retval
                    }
                    
                    guard let firstDayOfFollowingMonth = NSDate.startOfMonthForDate(followingMonth, usingCalendar: calendar) else {
                        print("Error generating date in indexPathOfdateCellCounterPart(). Contact the developer on github")
                        return retval
                    }
                    let indexPathOfFirstDayOfFollowingMonth = pathsFromDates([firstDayOfFollowingMonth])
                    if indexPathOfFirstDayOfFollowingMonth.count > 0 {
                        let firstDayIndex = indexPathOfFirstDayOfFollowingMonth[0].item
                        
                        
                        let lastDay = NSDate.endOfMonthForDate(date, usingCalendar: calendar)!
                        let lastDayIndex = calendar.components(.Day, fromDate: lastDay).day
                        
                        let x = lastDayIndex - dayIndex
                        let y = firstDayIndex - x - 1
                        
                        if y > -1 {
                            return NSIndexPath(forItem: y, inSection: indexPathOfFirstDayOfFollowingMonth[0].section)
                        }
                    } else {
                        print("out of range error in indexPathOfdateCellCounterPart() lower. This should not happen. Contact developer on github")
                    }
                }
            }
            
        }
        return retval
    }
    
    func scrollToSection(section: Int, triggerScrollToDateDelegate: Bool = false, animateScroll: Bool = true, completionHandler: (()->Void)?) {
        if scrollInProgress { return }
        if let date = dateFromPath(NSIndexPath(forItem: MAX_NUMBER_OF_DAYS_IN_WEEK - 1, inSection:section)) {
            let recalcDate = NSDate.startOfMonthForDate(date, usingCalendar: calendar)!
            self.scrollToDate(recalcDate, triggerScrollToDateDelegate: triggerScrollToDateDelegate, animateScroll: animateScroll, preferredScrollPosition: nil, completionHandler: completionHandler)
        }
    }
    
    func generateNewLayout() -> UICollectionViewLayout {
        let layout: UICollectionViewLayout = JTAppleCalendarLayout(withDelegate: self)
        let conformingProtocolLayout = layout as! JTAppleCalendarLayoutProtocol
        
        conformingProtocolLayout.scrollDirection = direction
        return layout
    }
    
    private func setupMonthInfoDataForStartAndEndDate()-> [[Int]] {
        var retval: [[Int]] = []
        if var validConfig = dataSource?.configureCalendar(self) {
            // check if the dates are in correct order
            if validConfig.calendar.compareDate(validConfig.startDate, toDate: validConfig.endDate, toUnitGranularity: NSCalendarUnit.Nanosecond) == NSComparisonResult.OrderedDescending {
                assert(false, "Error, your start date cannot be greater than your end date\n")
                return retval
            }
            
            // Check to see if we have a valid number of rows
            switch validConfig.numberOfRows {
            case 1, 2, 3:
                break
            default:
                validConfig.numberOfRows = 6
            }
            
            // Set the new cache
            cachedConfiguration = validConfig
            
            if let
                startMonth = NSDate.startOfMonthForDate(validConfig.startDate, usingCalendar: validConfig.calendar),
                endMonth = NSDate.endOfMonthForDate(validConfig.endDate, usingCalendar: validConfig.calendar) {
                
                startOfMonthCache = startMonth
                endOfMonthCache = endMonth
                
                let differenceComponents = validConfig.calendar.components(
                    NSCalendarUnit.Month,
                    fromDate: startOfMonthCache,
                    toDate: endOfMonthCache,
                    options: []
                )
                
                // Create boundary date
                let leftDate = validConfig.calendar.dateByAddingUnit(.Weekday, value: -1, toDate: startOfMonthCache, options: [])!
                let leftDateInt = validConfig.calendar.component(.Day, fromDate: leftDate)
                
                // Number of months
                numberOfMonths = differenceComponents.month + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
                
                // Number of sections in each month
                numberOfSectionsPerMonth = Int(ceil(Float(MAX_NUMBER_OF_ROWS_PER_MONTH)  / Float(cachedConfiguration.numberOfRows)))

                // Section represents # of months. section is used as an offset to determine which month to calculate
                for numberOfMonthsIndex in 0 ... numberOfMonths - 1 {
                    if let correctMonthForSectionDate = validConfig.calendar.dateByAddingUnit(.Month, value: numberOfMonthsIndex, toDate: startOfMonthCache, options: []) {
                        
                        let numberOfDaysInMonth = validConfig.calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: correctMonthForSectionDate).length
                        
                        var firstWeekdayOfMonthIndex = validConfig.calendar.component(.Weekday, fromDate: correctMonthForSectionDate)
                        firstWeekdayOfMonthIndex -= 1 // firstWeekdayOfMonthIndex should be 0-Indexed
                        

                        var firstDayCalValue = 0
                        switch firstDayOfWeek {
                            case .Monday: firstDayCalValue = 6 case .Tuesday: firstDayCalValue = 5 case .Wednesday: firstDayCalValue = 4
                            case .Thursday: firstDayCalValue = 10 case .Friday: firstDayCalValue = 9
                            case .Saturday: firstDayCalValue = 8 default: firstDayCalValue = 7
                        }
                        
                        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + firstDayCalValue) % 7 // push it modularly so that we take it back one day so that the first day is Monday instead of Sunday which is the default
                        
                        
                        // We have number of days in month, now lets see how these days will be allotted into the number of sections in the month
                        // We will add the first segment manually to handle the fdIndex inset
                        let aFullSection = (cachedConfiguration.numberOfRows * MAX_NUMBER_OF_DAYS_IN_WEEK)
                        var numberOfDaysInFirstSection = aFullSection - firstWeekdayOfMonthIndex
                        
                        // If the number of days in first section is greater that the days of the month, then use days of month instead
                        if numberOfDaysInFirstSection > numberOfDaysInMonth {
                            numberOfDaysInFirstSection = numberOfDaysInMonth
                        }
                        
                        let firstSectionDetail: [Int] = [firstWeekdayOfMonthIndex, numberOfDaysInFirstSection, 0, numberOfDaysInMonth] //fdIndex, numberofDaysInMonth, offset
                        retval.append(firstSectionDetail)
                        let numberOfSectionsLeft = numberOfSectionsPerMonth - 1
                        
                        // Continue adding other segment details in loop
                        if numberOfSectionsLeft < 1 {continue} // Continue if there are no more sections
                        
                        var numberOfDaysLeft = numberOfDaysInMonth - numberOfDaysInFirstSection
                        for _ in 0 ... numberOfSectionsLeft - 1 {
                            switch numberOfDaysLeft {
                            case _ where numberOfDaysLeft <= aFullSection: // Partial rows
                                let midSectionDetail: [Int] = [0, numberOfDaysLeft, firstWeekdayOfMonthIndex]
                                retval.append(midSectionDetail)
                                numberOfDaysLeft = 0
                            case _ where numberOfDaysLeft > aFullSection: // Full Rows
                                let lastPopulatedSectionDetail: [Int] = [0, aFullSection, firstWeekdayOfMonthIndex]
                                retval.append(lastPopulatedSectionDetail)
                                numberOfDaysLeft -= aFullSection
                            default:
                                break
                            }
                        }
                    }
                }
                retval[0].append(leftDateInt)
            }
        }
        return retval
    }
    
    func pathsFromDates(dates:[NSDate])-> [NSIndexPath] {
        var returnPaths: [NSIndexPath] = []
        for date in dates {
            if  calendar.startOfDayForDate(date) >= startOfMonthCache && calendar.startOfDayForDate(date) <= endOfMonthCache {
                let periodApart = calendar.components(.Month, fromDate: startOfMonthCache, toDate: date, options: [])
                let monthSectionIndex = periodApart.month
                let startSectionIndex = monthSectionIndex * numberOfSectionsPerMonth
                let sectionIndex = startMonthSectionForSection(startSectionIndex) // Get the section within the month
                
                // Get the section Information
                let currentMonthInfo = monthInfo[sectionIndex]
                let dayIndex = calendar.components(.Day, fromDate: date).day
                
                // Given the following, find the index Path
                let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
                let cellIndex = dayIndex + fdIndex - 1
                let updatedSection = cellIndex / numberOfItemsPerSection
                let adjustedSection = sectionIndex + updatedSection
                let adjustedCellIndex = cellIndex - (numberOfItemsPerSection * (cellIndex / numberOfItemsPerSection))
                returnPaths.append(NSIndexPath(forItem: adjustedCellIndex, inSection: adjustedSection))
            }
        }
        return returnPaths
    }
}

extension JTAppleCalendarView {
    func cellStateFromIndexPath(indexPath: NSIndexPath, withDate date: NSDate, cell: JTAppleDayCell? = nil)->CellState {
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        let componentDay = calendar.component(.Day, fromDate: date)
        let componentWeekDay = calendar.component(.Weekday, fromDate: date)
        let cellText = String(componentDay)
        let dateBelongsTo: CellState.DateOwner
        
        if itemIndex >= fdIndex && itemIndex < fdIndex + nDays {
            dateBelongsTo = .ThisMonth
        } else if itemIndex < fdIndex  && itemSection - 1 > -1  { // Prior month is available
            dateBelongsTo = .PreviousMonthWithinBoundary
        } else if itemIndex >= fdIndex + nDays && itemSection + 1 < monthInfo.count { // Following months
            dateBelongsTo = .FollowingMonthWithinBoundary
        } else if itemIndex < fdIndex { // Pre from the start
            dateBelongsTo = .PreviousMonthOutsideBoundary
        } else { // Post from the end
            dateBelongsTo = .FollowingMonthOutsideBoundary
        }
        
        let dayOfWeek = DaysOfWeek(rawValue: componentWeekDay)!

        let cellState = CellState(
            isSelected: theSelectedIndexPaths.contains(indexPath),
            text: cellText,
            dateBelongsTo: dateBelongsTo,
            date: date,
            day: dayOfWeek,
            row: {()->Int in return itemIndex / MAX_NUMBER_OF_DAYS_IN_WEEK },
            column: {()->Int in return itemIndex % MAX_NUMBER_OF_DAYS_IN_WEEK },
            dateSection: {()->(startDate: NSDate, endDate: NSDate) in return self.dateFromSection(itemSection)! },
            cell: {()->JTAppleDayCell? in return cell}
        )
        return cellState
    }
    
    func startMonthSectionForSection(aSection: Int)->Int {
        let monthIndexWeAreOn = aSection / numberOfSectionsPerMonth
        let nextSection = numberOfSectionsPerMonth * monthIndexWeAreOn
        return nextSection
    }
    
    func batchReloadIndexPaths(indexPaths: [NSIndexPath]) {
        if indexPaths.count < 1 { return }
        UICollectionView.performWithoutAnimation({
            self.calendarView.performBatchUpdates({
                self.calendarView.reloadItemsAtIndexPaths(indexPaths)
                }, completion: nil)  
        })
    }
    
    func addCellToSelectedSetIfUnselected(indexPath: NSIndexPath, date: NSDate) {
        if self.theSelectedIndexPaths.contains(indexPath) == false {
            self.theSelectedIndexPaths.append(indexPath)
            self.theSelectedDates.append(date)
        }
    }
    func deleteCellFromSelectedSetIfSelected(indexPath: NSIndexPath) {
        if let index = self.theSelectedIndexPaths.indexOf(indexPath) {
            self.theSelectedIndexPaths.removeAtIndex(index)
            self.theSelectedDates.removeAtIndex(index)
        }
    }
    func deselectCounterPartCellIndexPath(indexPath: NSIndexPath, date: NSDate, dateOwner: CellState.DateOwner) -> NSIndexPath? {
        if let
            counterPartCellIndexPath = indexPathOfdateCellCounterPart(date, indexPath: indexPath, dateOwner: dateOwner) {
            deleteCellFromSelectedSetIfSelected(counterPartCellIndexPath)
            return counterPartCellIndexPath
        }
        return nil
    }
    
    func selectCounterPartCellIndexPathIfExists(indexPath: NSIndexPath, date: NSDate, dateOwner: CellState.DateOwner) -> NSIndexPath? {
        if let counterPartCellIndexPath = indexPathOfdateCellCounterPart(date, indexPath: indexPath, dateOwner: dateOwner) {
            
            let dateComps = calendar.components([.Month, .Day, .Year], fromDate: date)
            guard let counterpartDate = calendar.dateFromComponents(dateComps) else {
                return nil
            }
            
            addCellToSelectedSetIfUnselected(counterPartCellIndexPath, date:counterpartDate)
            return counterPartCellIndexPath
        }
        return nil
    }
    
    func dateFromPath(indexPath: NSIndexPath)-> NSDate? { // Returns nil if date is out of scope
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let monthIndexWeAreOn = itemSection / numberOfSectionsPerMonth
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let offSet = currentMonthInfo[OFFSET_CALC]
        let cellDate = (cachedConfiguration.numberOfRows * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - fdIndex - offSet + 1
        
        dateComponents.month = monthIndexWeAreOn
        dateComponents.weekday = cellDate - 1
        
        return calendar.dateByAddingComponents(dateComponents, toDate: startOfMonthCache, options: [])
    }
}

extension JTAppleCalendarView: JTAppleCalendarDelegateProtocol {
    func numberOfRows() -> Int {return cachedConfiguration.numberOfRows}
    func numberOfColumns() -> Int { return MAX_NUMBER_OF_DAYS_IN_WEEK }
    func numberOfsectionsPermonth() -> Int { return numberOfSectionsPerMonth }
    func numberOfMonthsInCalendar() -> Int { return numberOfMonths }
    func numberOfDaysPerSection() -> Int { return numberOfItemsPerSection }
    
    func referenceSizeForHeaderInSection(section: Int) -> CGSize {
        if registeredHeaderViews.count < 1 { return CGSizeZero }
        return calendarViewHeaderSizeForSection(section)
    }
    
}
