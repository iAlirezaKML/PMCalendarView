//
//  PMCalendarMonthSelectorView.swift
//  PMCalendar
//
//  Created by Alireza Kamali on 12/1/15.
//  Copyright © 2015 Alireza Kamali. All rights reserved.
//

import UIKit

class PMCalendarMonthSelectorView: UIView {
	private let kPrevButtonImage:UIImage! = UIImage(named: "PMCalendar-prev-month", inBundle: NSBundle(forClass: PMCalendarView.self), compatibleWithTraitCollection: nil)
	private let kNextButtonImage:UIImage! = UIImage(named: "PMCalendar-next-month", inBundle: NSBundle(forClass: PMCalendarView.self), compatibleWithTraitCollection: nil)
	private let kMonthColor:UIColor!      = UIColor(red:0.475, green:0.475, blue:0.475, alpha: 1)
	private let kMonthFont:UIFont!        = UIFont(name: "Avenir-Medium", size: 16)
	private let kSeperatorColor:UIColor!  = UIColor(red:0.973, green:0.973, blue:0.973, alpha: 1)
	private let kSeperatorWidth:CGFloat!  = 1.5
	
	var prevButton: UIButton!
	var nextButton: UIButton!
	var monthLabel: UILabel!
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let buttoPMidth = floor(frame.width/7)
		prevButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttoPMidth, height: frame.height))
		prevButton.setImage(kPrevButtonImage, forState: .Normal)
		
		nextButton = UIButton(frame: CGRect(x: frame.width-buttoPMidth, y: 0, width: buttoPMidth, height: frame.height))
		nextButton.setImage(kNextButtonImage, forState: .Normal)
		
		monthLabel = UILabel(frame: CGRect(x: buttoPMidth, y: 0, width: frame.width-(2*buttoPMidth), height: frame.height))
		monthLabel.textAlignment = .Center
		monthLabel.textColor = kMonthColor
		monthLabel.font = kMonthFont
		monthLabel.text = "January 2015"
		
		addSubview(prevButton)
		addSubview(nextButton)
		addSubview(monthLabel)
		
		addSeperator(0)
		addSeperator(frame.height-kSeperatorWidth)
	}
	
	
	private func addSeperator(y: CGFloat) {
		let seperator = CALayer()
		seperator.backgroundColor = kSeperatorColor.CGColor
		seperator.frame = CGRect(x: 0, y: y, width: frame.width, height: kSeperatorWidth)
		layer.addSublayer(seperator)
	}
}

extension PMCalendarMonthSelectorView {
	func updateMonthLabelForMonth(month: NSDateComponents) {
		let formatter = NSDateFormatter()
		formatter.calendar = month.calendar
		formatter.locale = month.calendar?.locale
		formatter.dateFormat = "MMMM yyyy"
		let date = month.calendar?.dateFromComponents(month)
		monthLabel.text = formatter.stringFromDate(date!)
	}
}
