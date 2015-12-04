//
//  PMCalendarMonthView.swift
//  PMCalendar
//
//  Created by Peymayesh on 9/13/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import UIKit

protocol PMCalendarMonthViewDelegate {
	func didSelectDay(dayView: PMCalendarDayView, notifyDelegate: Bool)
	func selectDay(dayView: PMCalendarDayView)
}

class PMCalendarMonthView: UIView {
	private let kRowCount: CGFloat     = 6
	private let kNumberOfDaysPerWeek   = 7
	
	var delegate: PMCalendarMonthViewDelegate?
	
	var month        : NSDateComponents!
	var dayViewHeight: CGFloat!
	var columPMidths :[CGFloat]?
	var numberOfWeeks: Int!
	
	var locale = NSLocale.autoupdatingCurrentLocale()
	
	var dayViewsDict = Dictionary<String, PMCalendarDayView>()
	
	var dayViews:Set<PMCalendarDayView> {
		return Set(dayViewsDict.values)
	}
	
	var isCurrentMonth: Bool! = false {
		didSet {
			if isCurrentMonth == true {
				for dayView in dayViews {
					dayView.isActiveMonth = true
				}
				
			} else {
				for dayView in dayViews {
					dayView.isActiveMonth = false
				}
				
			}
		}
	}
	
	var disabledDates:[NSDateComponents]? {
		didSet {
			if let dates = disabledDates {
				for disabledDate in dates {
					let key = dayViewKeyForDay(disabledDate)
					let dayView = dayViewsDict[key]
					dayView?.isEnabled = false
				}
			}
			
		}
	}
	
	var availableDates:[NSDateComponents]? {
		didSet {
			if let availableDates = self.availableDates {
				for dayView in dayViews {
					if availableDates.contains(dayView.day!) {
						dayView.isEnabled = true
					} else {
						dayView.isEnabled = false
					}
				}
			}
		}
	}
	
	var selectedDates:[NSDateComponents]? {
		didSet {
			if let dates = selectedDates {
				for selectedDate in dates {
					let key = dayViewKeyForDay(selectedDate)
					if let dayView = dayViewsDict[key] {
						delegate?.selectDay(dayView)
					}
					
				}
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init(frame: CGRect, locale: NSLocale) {
		super.init(frame: frame)
		self.locale = locale
	}
	
	convenience init(month: NSDateComponents, width: CGFloat, height: CGFloat, locale: NSLocale) {
		self.init(frame: CGRect(x: 0, y: 0, width: width, height: height), locale: locale)
		backgroundColor = UIColor.clearColor()
		dayViewHeight = frame.height/kRowCount
		self.month = month
		calculateColumPMidths()
		createDays()
		numberOfWeeks = month.calendar!.rangeOfUnit(.WeekOfMonth, inUnit: .Month, forDate: month.date!).length
	}
	
	func disableMonth() {
		for dayView in dayViews {
			dayView.isEnabled = false
		}
	}
	
	func dayViewForDay(day: NSDateComponents) -> PMCalendarDayView? {
		let dayViewKey = dayViewKeyForDay(day)
		return dayViewsDict[dayViewKey]
	}
	
	
}

// MARK: - Layout
extension PMCalendarMonthView {
	func createDays() {
		var day = NSDateComponents()
		day.calendar = month.calendar
		day.day = 1
		day.month = month.month
		day.year = month.year
		
		
		let firstDate = day.calendar?.dateFromComponents(day)
		day = firstDate!.PMCalendarView_dayWithCalendar(month.calendar!)
		
		let numberOfDaysInMonth = day.calendar?.rangeOfUnit(.Day, inUnit: .Month, forDate: day.date!).length
		
		var startColumn = day.weekday - day.calendar!.firstWeekday
		if startColumn < 0 {
			startColumn += kNumberOfDaysPerWeek
		}
		
		var nextDayViewOrigin = CGPointZero
		for (var column = 0; column < startColumn; column++) {
			nextDayViewOrigin.x += columPMidths![column]
		}
		
		
		repeat {
			for(var column = startColumn; column < kNumberOfDaysPerWeek; column++) {
				if day.month == month.month {
					let dayView = createDayView(nextDayViewOrigin, width: columPMidths![column])
					dayView.delegate = self
					dayView.setDayForDay(day)
					let dayViewKey = dayViewKeyForDay(day)
					dayViewsDict[dayViewKey] = dayView
					addSubview(dayView)
				}
				day.day += 1
				nextDayViewOrigin.x += columPMidths![column]
				
				if day.day > numberOfDaysInMonth {
					break
				}
			}
			
			nextDayViewOrigin.x = 0
			nextDayViewOrigin.y += dayViewHeight
			startColumn = 0
		} while (day.day <= numberOfDaysInMonth)
		
	}
	
	func createDayView(origin: CGPoint, width: CGFloat)-> PMCalendarDayView {
		var dayFrame = CGRectZero
		dayFrame.origin = origin
		dayFrame.size.width = width
		dayFrame.size.height = dayViewHeight
		
		return PMCalendarDayView(frame: dayFrame, locale: locale)
	}
	
	
	func calculateColumPMidths() {
		columPMidths = PMCalendarCache.sharedCache.objectForKey(kNumberOfDaysPerWeek) as? [CGFloat]
		if columPMidths == nil {
			let columnCount:CGFloat = CGFloat(kNumberOfDaysPerWeek)
			let width      :CGFloat = floor(bounds.size.width / CGFloat(columnCount))
			var remainder  :CGFloat = bounds.size.width - (width * CGFloat(columnCount))
			var padding    :CGFloat = 1
			
			columPMidths = [CGFloat](count: kNumberOfDaysPerWeek, repeatedValue: width)
			
			if remainder > columnCount {
				padding = ceil(remainder/columnCount)
			}
			
			
			for (index, _) in (columPMidths!).enumerate() {
				columPMidths![index] = width + padding
				
				remainder -= padding
				if remainder < 1 {
					break
				}
			}
			PMCalendarCache.sharedCache.setObjectForKey(columPMidths!, key: kNumberOfDaysPerWeek)
		}
		
	}
	
	func dayViewKeyForDay(day: NSDateComponents) -> String {
		return "\(day.month)/\(day.day)/\(day.year)"
	}
}

// MARK: - Touch Handling
extension PMCalendarMonthView {
	override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
		for subview in subviews {
			if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
				return true
			}
		}
		return false
	}
}

// MARK: - PMCalendarDayViewDelegate
extension PMCalendarMonthView: PMCalendarDayViewDelegate {
	func dayButtonPressed(dayView: PMCalendarDayView) {
		delegate?.didSelectDay(dayView, notifyDelegate: true)
	}
}