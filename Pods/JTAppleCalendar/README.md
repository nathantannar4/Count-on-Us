![JTAppleCalendar](Images/JTAppleCalendar.jpg)

The final iOS calendar control you'll ever try


Inspiration for this control was made possible by Michael @ Karmadust. Want to know how the calendar control works inside out? [Check out his KDCalendar tutorial.](http://blog.karmadust.com/lets-create-a-calendar-using-a-uicollectionview/)


[![CI Status](http://img.shields.io/travis/patchthecode/JTAppleCalendar.svg?style=flat)](https://travis-ci.org/patchthecode/JTAppleCalendar) [![Version](https://img.shields.io/cocoapods/v/JTAppleCalendar.svg?style=flat)](http://cocoapods.org/pods/JTAppleCalendar) [![License](https://img.shields.io/cocoapods/l/JTAppleCalendar.svg?style=flat)](http://cocoapods.org/pods/JTAppleCalendar) [![Platform](https://img.shields.io/cocoapods/p/JTAppleCalendar.svg?style=flat)](http://cocoapods.org/pods/JTAppleCalendar)
[![](https://www.paypalobjects.com/webstatic/en_US/btn/btn_donate_74x21.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7YVDC37NDZP8S)

### **Screenshots**
The look of this calendar is up to the developer. Check out what people have developed with this library and also post your own images [at this link](https://github.com/patchthecode/JTAppleCalendar/issues/2). A sample iOS application is also included in this project's [Github Repository](https://github.com/patchthecode/JTAppleCalendar) to give you an idea of what you can do.

* Downloaded and liked this calendar's ease of use?
* Then don't forget to leave a ★ Star rating on Github. It's needed to make this control #1 :)
* Also, [Support](https://salt.bountysource.com/teams/jtapplecalendar) is not manditory, but will be much appreciated. Let's keep ~~OpenSource~~ good OpenSource projects alive.

### **Features**
---

- [x] Boundary dates - limit the calendar date range
- [x] Week/month mode - show 1 row of weekdays. Or 2, 3 or 6
- [x] Custom cells - make your day-cells look however you want, with any functionality you want
- [x] Custom calendar view - make your calendar look however you want, with what ever functionality you want
- [x] First Day of week - pick anyday to be first day of the week
- [x] Horizontal or vertical mode
- [x] Ability to add month headers in varying sizes/styles of your liking
- [x] Ability to scroll to any month by simply using the date
- [x] Ability to design your calendar [however you want.](https://github.com/patchthecode/JTAppleCalendar/issues/2) You want it, you build it
- [x] [Complete Documentation](http://cocoadocs.org/docsets/JTAppleCalendar)

### **The Problem**
---

1. Apple has no calendar control.
2. Other calendar projects on Github try to cram every feature into their control, hoping it will meet the programmer's requirements.

This is an incorrect way to build controls. It leaves the developer with an extremely wide selection of (in many cases non-conventional) features that he has to sift through in order to configure the calendar. Also, no matter how wide the feature selection, the developer is always restricted to a predefined configuration-set shipped with the calendarControl.  Do you see Apple building their `UITableView` by guessing what they think you want the UITableView to look like? No. So neither should we. 

### **The Solution: JTAppleCalendar**
---

#### [Click here to check out a quick tutorial](https://github.com/patchthecode/JTAppleCalendar/wiki)

#### Properties/functions/structs to help configure your calendar


The following structure was returned when a cell is about to be displayed.

```swift
    public enum DateOwner: Int {
        case ThisMonth = 0, PreviousMonthWithinBoundary, PreviousMonthOutsideBoundary, FollowingMonthWithinBoundary, FollowingMonthOutsideBoundary
    }
```


* `.ThisMonth` = the date to be displayed belongs to the month section
* `.PreviousMonthWithinBoundary` = date belongs to the previous month, and it is within the date boundary you set
* `.PreviousMonthOutsideBoundary` = date belongs to previous month, and it is outside the boundary you have set
* `.FollowingMonthWithinBoundary` = date belongs to following month, within boundary
* `.FollowingMonthOutsideBoundary` = date belongs to following month, outside boundary

#### User functions

```swift
    public func reloadData()
    public func reloadDates(dates: [NSDate])
    public func scrollToNextSegment() 
    public func scrollToPreviousSegment()
    public func scrollToDate()
    public func selectDates()
    public func cellStatusForDateAtRow(row: Int, column: Int) -> CellState?
    public func currentCalendarDateSegment() -> (startDate: NSDate, endDate: NSDate)
    public func scrollToHeaderForDate(date: NSDate)
```

#### Properties you can configure
```swift
// Note: You do not need to configure your calendar with this if it is already the default
calendarView.direction = .Horizontal                       // default is horizontal
calendarView.numberOfRowsPerMonth                          // default is 6. This is now setup in the configure Datasource Delegate Methhod
calendarView.cellInset = CGPoint(x: 0, y: 0)               // default is (3,3)
calendarView.allowsMultipleSelection = false               // default is false
calendarView.bufferTop = 0                                 // default is 0. - still work in progress
calendarView.bufferBottom = 0                              // default is 0. - still work in progress
calendarView.firstDayOfWeek = .Sunday                      // default is Sunday
calendarView.scrollEnabled = true                          // default is true
calendarView.pagingEnabled = true                          // default is true
calendarView.scrollResistance = 0.75                       // default is 0.75 - this is only applicable when paging is not enabled
```

Do you have any other questions?. If you are trying to bend heaven and earth to do something complicated with this calendar, then chances are there is already an easy way for it to be done. So [Opening an issue](https://github.com/patchthecode/JTAppleCalendar/issues/new) might be a good idea.

Did you remember to leave a like? I would really appreciate it if you did. 

Other functions/properties are coming. This is a very active project.

### **Requirements**
---

* iOS 8.0+ 
* Xcode 7.2+



### **Communication on Github**
---
* Found a bug? [open an issue](https://github.com/patchthecode/JTAppleCalendar/issues)
* Got a cool feature request? [open an issue](https://github.com/patchthecode/JTAppleCalendar/issues)
* Need a question answered? [open an issue](https://github.com/patchthecode/JTAppleCalendar/issues) 


### **Installation using CocoaPods**

CocoaPods is a dependency manager for Cocoa projects. Cocoapods can be installed with the following command:

$ gem install cocoapods



> CocoaPods 0.39.0+ is required to build JTAppleCalendar

To integrate JTAppleCalendar into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
platform :ios, '8.0'
use_frameworks!

pod 'JTAppleCalendar'
```

Then, run the following command at your project location:

```bash
$ pod install
```


## Author

JayT, patchthecode@gmail.com

## License

JTAppleCalendar is available under the MIT license. See the LICENSE file for more info.
