//
//  PMCalendarHeaderView.swift
//  PMCalendarView
//
//  Created by Peymayesh on 10/5/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import UIKit

public class PMCalendarHeaderView: UILabel {
	private let leftButton = UIButton()
	private let rightButton = UIButton()
	
	private weak var calendarView: PMCalendarView!
	
	private lazy var dateFormatter: NSDateFormatter = {
		[unowned self] in
		let formatter = NSDateFormatter()
		formatter.calendar = self.calendarView.calendar
		formatter.locale = self.calendarView.locale
		formatter.dateFormat = self.dateFormat
		return formatter
	}()
	
	public var dateFormat = "MMMM y"
	
	public override var backgroundColor: UIColor? {
		set {
			layer.backgroundColor = newValue?.CGColor
		}
		get {
			return .clearColor()
		}
	}
	public override var tintColor: UIColor! {
		didSet {
			leftButton.tintColor = tintColor
			rightButton.tintColor = tintColor
		}
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("HeaderView: IB not Supported!")
	}
	
	public init(forCalendarView calendarView: PMCalendarView) {
		super.init(frame: CGRectZero)
		
		self.calendarView = calendarView
		calendarView.headerView = self
		
		userInteractionEnabled = true
		addSubview(leftButton)
		addSubview(rightButton)
		textAlignment = .Center
		leftButton.addTarget(self, action: #selector(PMCalendarHeaderView.changePage(_:)), forControlEvents: .TouchUpInside)
		rightButton.addTarget(self, action: #selector(PMCalendarHeaderView.changePage(_:)), forControlEvents: .TouchUpInside)
		let leftImage = UIImage(named: "left", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
		let rightImage = UIImage(named: "right", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
		leftButton.setImage(leftImage, forState: .Normal)
		rightButton.setImage(rightImage, forState: .Normal)
		leftButton.tag = 1
		rightButton.tag = 2
		leftButton.translatesAutoresizingMaskIntoConstraints = false
		rightButton.translatesAutoresizingMaskIntoConstraints = false
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[b(40)]", options: [], metrics: nil, views: ["b" : leftButton]))
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[b(40)]-|", options: [], metrics: nil, views: ["b" : rightButton]))
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[b]|", options: [], metrics: nil, views: ["b" : leftButton]))
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[b]|", options: [], metrics: nil, views: ["b" : rightButton]))
	}
	
	func changePage(sender: UIButton) {
		let isNext = calendarView.rightToLeftLayout && sender.tag == 1
		isNext ? calendarView.scrollToNextSegment() : calendarView.scrollToPreviousSegment()
	}
	
	func updateToDate(date: NSDate) {
		text = dateFormatter.stringFromDate(date)
	}
}
