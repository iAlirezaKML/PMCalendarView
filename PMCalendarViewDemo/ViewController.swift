//
//  ViewController.swift
//  PMCalendarViewDemo
//
//  Created by Peymayesh on 2/1/1395 .
//  Copyright © 1395 AP Peymayesh. All rights reserved.
//

import UIKit
import PMCalendarView

class ViewController: UIViewController {

	
	let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierPersian) ?? NSCalendar.currentCalendar()
	let locale = NSLocale(localeIdentifier: "fa_IR")
	
	lazy var formatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.locale = self.locale
		formatter.dateStyle = .MediumStyle
		return formatter
	}()
	
	var headerView: PMCalendarHeaderView!
	var weekdaysView: PMCalendarWeekdaysView!
	var calendarView: PMCalendarView!
	
	func commonInit() {
		view.backgroundColor = .whiteColor()
		addsubview()
	}
	
	func addsubview() {
		if calendarView == nil {
			calendarView = PMCalendarView(withDataSource: self, cellClass: CellView.self)
			calendarView.delegate = self
			calendarView.direction = .Horizontal
			calendarView.rightToLeftLayout = true
			calendarView.numberOfRowsPerMonth = 6
			calendarView.allowsMultipleSelection = false
			calendarView.bufferTop = 0
			calendarView.bufferBottom = 0
			calendarView.firstDayOfWeek = .Saturday
			calendarView.scrollEnabled = true
			
			headerView = PMCalendarHeaderView(forCalendarView: calendarView)
			headerView.textColor = .whiteColor()
			headerView.backgroundColor = UIColor.lightGrayColor()
			weekdaysView = PMCalendarWeekdaysView(forCalendarView: calendarView)
			weekdaysView.font = UIFont.systemFontOfSize(10)
			weekdaysView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
			
			calendarView.reloadData()
		}
		
		headerView.translatesAutoresizingMaskIntoConstraints = false
		weekdaysView.translatesAutoresizingMaskIntoConstraints = false
		calendarView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(headerView)
		view.addSubview(weekdaysView)
		view.addSubview(calendarView)
		
		let hHeight: CGFloat = 38
		let wdHeight: CGFloat = 18
		
		calendarView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
		calendarView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: hHeight).active = true
		calendarView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 0.8).active = true
		calendarView.heightAnchor.constraintEqualToAnchor(calendarView.widthAnchor).active = true
		
		headerView.heightAnchor.constraintEqualToConstant(hHeight).active = true
		headerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
		headerView.bottomAnchor.constraintEqualToAnchor(weekdaysView.topAnchor).active = true
		headerView.widthAnchor.constraintEqualToAnchor(calendarView.widthAnchor).active = true
		
		weekdaysView.bottomAnchor.constraintEqualToAnchor(calendarView.topAnchor).active = true
		weekdaysView.heightAnchor.constraintEqualToConstant(wdHeight).active = true
		weekdaysView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
		weekdaysView.widthAnchor.constraintEqualToAnchor(calendarView.widthAnchor).active = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		commonInit()
	}	
}


extension ViewController: PMCalendarViewDataSource {
	var calendarViewStartDate: NSDate {
		return calendar.dateByAddingUnit(.Month, value: 0, toDate: NSDate(), options: []) ?? NSDate()
	}
	
	var calendarViewEndDate: NSDate {
		return calendar.dateByAddingUnit(.Month, value: 4, toDate: NSDate(), options: []) ?? NSDate()
	}
	
	var calendarViewCalendar: NSCalendar {
		return calendar
	}
	
	var calendarViewLocale: NSLocale {
		return locale
	}
}

extension ViewController: PMCalendarViewDelegate {	
	func calendarView(calendarView: PMCalendarView, didSelectDate date: NSDate, state: PMCalendarDateState) {
		print(formatter.stringFromDate(date))
		if state.dateBelongsTo != .ThisMonth {
			calendarView.selectDates([date], triggerSelectionDelegate: false)
			calendarView.scrollToDate(date)
		}
	}
}
