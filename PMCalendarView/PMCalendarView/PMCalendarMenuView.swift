//
//  PMCalendarMenuView.swift
//  PMCalendar
//
//  Created by Peymayesh on 9/13/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import UIKit

protocol PMCalendarMenuViewDelegate {
	func prevMonthPressed()
	func nextMonthPressed()
}

class PMCalendarMenuView: UIView {
	private let kDayColor = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
	private let kDayFont  = UIFont(name: "Avenir-Roman", size: 10)
	
	var delegate         : PMCalendarMenuViewDelegate?
	var monthSelectorView: PMCalendarMonthSelectorView!
	var days             : [String]  = []
	var sectionHeight    : CGFloat {
		return frame.height/2
	}
	
	var locale = NSLocale.autoupdatingCurrentLocale()
	var calendar = NSCalendar.currentCalendar()
	
	init(locale: NSLocale, calendar: NSCalendar) {
		super.init(frame: .zero)
		self.locale = locale
		self.calendar = calendar
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init(frame: CGRect, locale: NSLocale, calendar: NSCalendar) {
		super.init(frame: frame)
		self.locale = locale
		self.calendar = calendar
		backgroundColor = UIColor.whiteColor()
		
		monthSelectorView = PMCalendarMonthSelectorView(frame: CGRect(x: 0, y: 0, width: frame.width, height: sectionHeight))
		monthSelectorView.prevButton.addTarget(self, action: "prevMonthPressed:", forControlEvents: .TouchUpInside)
		monthSelectorView.nextButton.addTarget(self, action: "nextMonthPressed:", forControlEvents: .TouchUpInside)
		addSubview(monthSelectorView)
		
		setupDays()
		setupDayLabels()
	}
	
	func setupDays() {
		days = calendar.weekdaySymbols
		let shift = calendar.firstWeekday - 6
		if shift > 0 {
			days.shiftRightInPlace(-shift)
		}
	}
	
	
	func setupDayLabels() {
		let width = frame.width / 7
		let height = sectionHeight
		
		var x:CGFloat = 0
		let y:CGFloat = CGRectGetMaxY(monthSelectorView.frame)
		
		for i in 0..<7 {
			x = CGFloat(i) * width
			createDayLabel(x, y: y, width: width, height: height, day: days[i])
		}
		
	}
	
	func createDayLabel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, day: String) {
		let dayLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
		dayLabel.textAlignment = .Center
		dayLabel.text = day.uppercaseString
		dayLabel.font = kDayFont
		dayLabel.textColor = kDayColor
		addSubview(dayLabel)
	}
	
}


// MARK: PMCalendarMonthSelectorView Actions
extension PMCalendarMenuView {
	func prevMonthPressed(sender: AnyObject) {
		delegate?.prevMonthPressed()
	}
	
	func nextMonthPressed(sender: AnyObject) {
		delegate?.nextMonthPressed()
	}
}
