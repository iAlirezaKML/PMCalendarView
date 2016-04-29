//
//  PMCalendarViewWeekDaysView.swift
//  PMCalendarView
//
//  Created by Peymayesh on 10/5/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import UIKit

public class PMCalendarWeekdaysView: UIView {
	private weak var calendarView: PMCalendarView!
	
	private var labels: MCLabel!

	public var font = UIFont.systemFontOfSize(14) { didSet { labels.font = font } }
	public var textColor = UIColor.darkGrayColor() { didSet { labels.textColor = textColor } }
	public var shortFormat = true { didSet { reloadText() } }
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("WeekDaysView: IB not Supported!")
	}
	
	public init(forCalendarView calendarView: PMCalendarView) {
		super.init(frame: CGRectZero)
		
		self.calendarView = calendarView
		calendarView.weekdaysView = self
		
		labels = MCLabel(frame: bounds)
		labels.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		addSubview(labels)
		
		labels.textAlignment = .Center
		labels.numberOfColumns = 7
		labels.font = font
		labels.textColor = textColor

		reloadText()
	}
	
	func reloadText() {
		let cal = calendarView.calendar.copy() as! NSCalendar
		cal.locale = calendarView.locale
		var weekdaySymbols = shortFormat ? cal.shortWeekdaySymbols : cal.weekdaySymbols
		let shift = calendarView.firstDayOfWeek.rawValue - calendarView.calendar.firstWeekday
		if shift > 0 { weekdaySymbols.shiftRightInPlace(shift) }
		if calendarView.rightToLeftLayout { weekdaySymbols.reverseInPlace() }
		var text = ""
		for (index, symbol) in weekdaySymbols.enumerate() {
			text += symbol
			if index != 6 { text += "\n" }
		}
		labels.text = text
	}	
}

private extension Array {
	func shiftRight(amount: Int = 1) -> [Element] {
		var shiftAmount = amount
		assert(-count...count ~= amount, "Shift amount out of bounds")
		if amount < 0 { shiftAmount += count }  // this needs to be >= 0
		return Array(self[shiftAmount ..< count] + self[0 ..< shiftAmount])
	}
	
	mutating func shiftRightInPlace(amount: Int = 1) {
		self = shiftRight(amount)
	}
	
	mutating func reverseInPlace() {
		self = reverse()
	}
}

