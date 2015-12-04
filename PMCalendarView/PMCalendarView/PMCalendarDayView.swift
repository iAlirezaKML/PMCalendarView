//
//  PMCalendarDayView.swift
//  PMCalendar
//
//  Created by Peymayesh on 9/13/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import Foundation
import UIKit

protocol PMCalendarDayViewDelegate {
	func dayButtonPressed(dayView: PMCalendarDayView)
}

class PMCalendarDayView: UIView {
	private let kDayFont             = UIFont(name: "Avenir-Roman", size: 14)
	private let kAvailableColor      = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
	private let kNotAvailableColor   = UIColor(red:0.890, green:0.890, blue:0.890, alpha: 1)
	private let kNonActiveMonthColor = UIColor(red:0.949, green:0.949, blue:0.949, alpha: 1)
	private let kActiveMonthColor    = UIColor.whiteColor()
	private let kSelectedColor       = UIColor(red:0.988, green:0.325, blue:0.341, alpha: 1)
	
	var locale = NSLocale.autoupdatingCurrentLocale()
	
	var delegate : PMCalendarDayViewDelegate?
	var dayButton: UIButton!
	var date     : NSDate? {
		didSet {
			if let uPMrappedDate = date {
				if uPMrappedDate.PMCalendarView_dayIsInPast() {
					isInPast = true
				}
			}
		}
	}
	
	var day: NSDateComponents? {
		didSet {
			date = day?.date
			let formatter = NSNumberFormatter()
			formatter.locale = locale
			if let string = formatter.stringFromNumber(day!.day) {
				dayButton.setTitle(string, forState: .Normal)
			}
		}
	}
	
	var isActiveMonth = false {
		didSet {
			setNotSelectedBackgroundColor()
		}
	}
	
	var isInPast = false {
		didSet {
			isEnabled = !isInPast
		}
	}
	
	var isEnabled = true {
		didSet {
			dayButton.enabled = isEnabled
		}
	}
	
	var isSelected = false {
		didSet {
			if isSelected {
				backgroundColor = kSelectedColor
				dayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
				dayButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
			} else {
				setNotSelectedBackgroundColor()
				dayButton.setTitleColor(kAvailableColor, forState: .Normal)
				dayButton.setTitleColor(kNotAvailableColor, forState: .Disabled)
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init(frame: CGRect, locale: NSLocale) {
		super.init(frame: frame)
		self.locale = locale
		backgroundColor = kNonActiveMonthColor
		
		dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
		dayButton.titleLabel?.textAlignment = .Center
		dayButton.titleLabel?.font = kDayFont
		dayButton.setTitleColor(kAvailableColor, forState: .Normal)
		dayButton.setTitleColor(kNotAvailableColor, forState: .Disabled)
		dayButton.addTarget(self, action: "dayButtonPressed:", forControlEvents: .TouchUpInside)
		addSubview(dayButton)
	}
	
	func dayButtonPressed(sender: AnyObject) {
		delegate?.dayButtonPressed(self)
	}
	
	func setDayForDay(day: NSDateComponents) {
		self.day = day.date!.PMCalendarView_dayWithCalendar(day.calendar!)
	}
	
	func setNotSelectedBackgroundColor() {
		if !isSelected {
			if isActiveMonth {
				backgroundColor = kActiveMonthColor
			} else {
				backgroundColor = kNonActiveMonthColor
			}
		}
	}
}