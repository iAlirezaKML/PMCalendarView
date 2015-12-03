//
//  ViewController.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/23/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	var calendarView: NWCalendarView!
	let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierPersian)!
	let locale = NSLocale(localeIdentifier: "fa_IR")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		calendar.locale = locale
		let size = min(view.bounds.width, view.bounds.height) * 0.9
		let frame = CGRectMake(0, 0, size, size)
		calendarView = NWCalendarView(frame: frame, calendar: calendar, locale: locale)
		self.view.addSubview(calendarView)

		calendarView.layer.borderColor = UIColor.grayColor().CGColor
		calendarView.layer.borderWidth = 0.1
		calendarView.layer.shadowColor = UIColor.blackColor().CGColor
		calendarView.layer.shadowOffset = CGSizeMake(0, 0)
		calendarView.layer.shadowOpacity = 0.3
		calendarView.layer.shadowRadius = 8
		calendarView.clipsToBounds = false

		calendarView.backgroundColor = UIColor.whiteColor()
		
		let date = NSDate()
		calendarView.selectedDates = [date]
		calendarView.selectionRangeLength = 1
		calendarView.maxMonths = 1
		calendarView.delegate = self
		calendarView.createCalendar()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		calendarView.center = self.view.center
	}
	
}

extension ViewController: NWCalendarViewDelegate {
	func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents) {
		let dateFormatter: NSDateFormatter = NSDateFormatter()
		dateFormatter.calendar = calendar
		dateFormatter.locale = locale
		let months = dateFormatter.standaloneMonthSymbols
		let fromMonthName = months[fromMonth.month-1] as String
		let toMonthName = months[toMonth.month-1] as String
		
		print("Change From '\(fromMonthName)' to '\(toMonthName)'")
	}
	
	func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents) {
		print("Selected date '\(fromDate.month)/\(fromDate.day)/\(fromDate.year)' to date '\(toDate.month)/\(toDate.day)/\(toDate.year)'")
	}
}