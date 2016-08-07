//
//  JTAppleDayCell.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

enum JTAppleCallendarCellViewSource {
    case fromXib(String)
    case fromType(AnyClass)
    case fromClassName(String)
}

var cellViewSource: JTAppleCallendarCellViewSource?
var internalCellInset: CGPoint = CGPoint(x: 3.0, y: 3.0)

/// The JTAppleDayCell class defines the attributes and behavior of the cells that appear in JTAppleCalendarView objects.
public class JTAppleDayCell: UICollectionViewCell {

	var cellView: JTAppleDayCellView!

	func setupCellView() {

		guard let cellSource = cellViewSource else {
			print("Did you remember to register your JTAppleCalendarView? Because we can't find any")
			return
		}

		var theView: JTAppleDayCellView

		switch cellSource {
		case let .fromXib(xibName):
			let viewObject = NSBundle.mainBundle().loadNibNamed(xibName, owner: self, options: [:])
			assert(viewObject.count > 0, "your nib file name \(xibName) could not be loaded)")

			guard let view = viewObject[0] as? JTAppleDayCellView else {
				print("xib file class does not conform to the protocol<JTAppleDayCellViewProtocol>")
				assert(false)
				return
			}
			theView = view
			break
		case let .fromClassName(cellClassName):
			guard let theCellClass = NSBundle.mainBundle().classNamed(cellClassName) as? JTAppleDayCellView.Type else {
				print("Error loading registered class: '\(cellClassName)'")
				print("Make sure that: \n\n(1) It is a subclass of: 'JTAppleDayCellView' \n(2) You registered your class using the fully qualified name like so -->  'theNameOfYourProject.theNameOfYourClass'\n")
				assert(false)
				return
			}
			theView = theCellClass.init()
			break

		case let .fromType(cellType):
			guard let theCellClass = cellType as? JTAppleDayCellView.Type else {
				print("Error loading registered class: '\(cellType)'")
				print("Make sure that: \n\n(1) It is a subclass of: 'JTAppleDayCellView'\n")
				assert(false)
				return
			}
			theView = theCellClass.init()
			break
		}

		updateCellView(theView)
	}

	func updateCellView(view: JTAppleDayCellView) {
		let vFrame = CGRectInset(self.frame, internalCellInset.x, internalCellInset.y)
		view.frame = vFrame
		view.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
		cellView = view
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupCellView()
		self.addSubview(cellView)
	}

	/// Returns an object initialized from data in a given unarchiver.
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
