//
//  CellView.swift
//  PMCalendarViewDemo
//
//  Created by Peymayesh on 2/1/1395 .
//  Copyright © 1395 AP Peymayesh. All rights reserved.
//

import UIKit
import PMCalendarView

class CellView: PMCalendarCell {
	var todayColor = UIColor(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.3)
	var normalDayColor = UIColor.clearColor()
	
	let selectedView = AnimationView()
	var backView: UIView!
	let supplimentaryView = UIView()
	let dayLabel = UILabel()
	
	let textSelectedColor = UIColor.whiteColor()
	let textDeselectedColor = UIColor.blackColor()
	let previousMonthTextColor = UIColor.grayColor()
	
	lazy var todayDate : String = {
		[unowned self] in
		let aString = self.c.stringFromDate(NSDate())
		return aString
	}()
	
	lazy var c : NSDateFormatter = {
		let f = NSDateFormatter()
		f.dateFormat = "yyyy-MM-dd"
		return f
	}()
	
	private func commonInit() {
		backView = UIView(frame: bounds)
		backView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		
		selectedView.translatesAutoresizingMaskIntoConstraints = false
		dayLabel.translatesAutoresizingMaskIntoConstraints = false
		supplimentaryView.translatesAutoresizingMaskIntoConstraints = false
		
		selectedView.backgroundColor = .redColor()
		
		addSubview(backView)
		addSubview(selectedView)
		addSubview(dayLabel)
		addSubview(supplimentaryView)
		
		addConstraint(NSLayoutConstraint(item: selectedView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
		addConstraint(NSLayoutConstraint(item: selectedView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
		
		addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
		addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))

		addConstraint(NSLayoutConstraint(item: supplimentaryView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
		addConstraint(NSLayoutConstraint(item: supplimentaryView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let maxSize = min(frame.width*0.8, frame.height*0.8)
		selectedView.frame.size = CGSizeMake(maxSize, maxSize)
		selectedView.frame.origin.x -= maxSize/2
		selectedView.frame.origin.y -= maxSize/2
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	override func calendarCell(isAboutToDisplayDate date: NSDate, state: PMCalendarDateState) {
		// Setup Cell text
		dayLabel.text = state.text
		
		// Setup text color
		configureTextColor(state)
		
		// Setup Cell Background color
		backView.backgroundColor = c.stringFromDate(date) == todayDate ? todayColor:normalDayColor
		
		// Setup cell selection status
		configueViewIntoBubbleView(state)
		
		// Configure Visibility
		configureVisibility(state)
	}
	
	override func calendarCell(didSelectDate date: NSDate, state: PMCalendarDateState) {
		cellSelectionChanged(state)
	}
	
	override func calendarCell(didDeselectDate date: NSDate, state: PMCalendarDateState) {
		cellSelectionChanged(state)
	}
	
	func configureVisibility(cellState: PMCalendarDateState) {
		if cellState.dateBelongsTo == .ThisMonth ||
			cellState.dateBelongsTo == .PreviousMonthWithinBoundary ||
			cellState.dateBelongsTo == .FollowingMonthWithinBoundary {
			self.hidden = false
		} else {
			self.hidden = false
		}
	}
	
	func configureTextColor(cellState: PMCalendarDateState) {
		if cellState.isSelected {
			dayLabel.textColor = textSelectedColor
		} else if cellState.dateBelongsTo == .ThisMonth {
			dayLabel.textColor = textDeselectedColor
		} else {
			dayLabel.textColor = previousMonthTextColor
		}
	}
	
	func cellSelectionChanged(cellState: PMCalendarDateState) {
		if cellState.isSelected == true {
			if selectedView.hidden == true {
				configueViewIntoBubbleView(cellState)
				self.userInteractionEnabled = false
				selectedView.animateWithBounceEffect(withCompletionHandler: {
					self.userInteractionEnabled = true
				})
			}
		} else {
			configueViewIntoBubbleView(cellState, animateDeselection: true)
		}
	}
	
	private func configueViewIntoBubbleView(cellState: PMCalendarDateState, animateDeselection: Bool = false) {
		if cellState.isSelected {
			delayRunOnMainThread(0.0, closure: {
				self.selectedView.layer.cornerRadius = self.selectedView.frame.width / 2
				self.selectedView.hidden = false
			})
			
			configureTextColor(cellState)
			
		} else {
			if animateDeselection {
				configureTextColor(cellState)
				if selectedView.hidden == false {
					self.userInteractionEnabled = false
					selectedView.animateWithFadeEffect(withCompletionHandler: { () -> Void in
						self.userInteractionEnabled = true
						self.selectedView.hidden = true
						self.selectedView.alpha = 1
					})
				}
			} else {
				selectedView.hidden = true
			}
		}
	}
	
	func delayRunOnMainThread(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
}

class AnimationView: UIView {
	
	func animateWithFlipEffect(withCompletionHandler completionHandler:(()->Void)?) {
		AnimationClass.flipAnimation(self, completion: completionHandler)
	}
	func animateWithBounceEffect(withCompletionHandler completionHandler:(()->Void)?) {
		let viewAnimation = AnimationClass.BounceEffect()
		viewAnimation(self){ _ in
			completionHandler?()
		}
	}
	func animateWithFadeEffect(withCompletionHandler completionHandler:(()->Void)?) {
		let viewAnimation = AnimationClass.FadeOutEffect()
		viewAnimation(self) { _ in
			completionHandler?()
		}
	}
}

class AnimationClass {
	class func BounceEffect() -> (UIView, Bool -> Void) -> () {
		return {
			view, completion in
			view.transform = CGAffineTransformMakeScale(0.5, 0.5)
			
			UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
				view.transform = CGAffineTransformMakeScale(1, 1)
				}, completion: completion)
		}
	}
	
	class func FadeOutEffect() -> (UIView, Bool -> Void) -> () {
		return {
			view, completion in
			
			UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
				view.alpha = 0
				}, completion: completion)
		}
	}
	
	private class func get3DTransformation(angle: Double) -> CATransform3D {
		
		var transform = CATransform3DIdentity
		transform.m34 = -1.0 / 500.0
		transform = CATransform3DRotate(transform, CGFloat(angle * M_PI / 180.0), 0, 1, 0.0)
		
		return transform
	}
	
	class func flipAnimation(view: UIView, completion: (() -> Void)?) {
		
		let angle = 180.0
		view.layer.transform = get3DTransformation(angle)
		
		UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .TransitionNone, animations: { () -> Void in
			view.layer.transform = CATransform3DIdentity
		}) { (finished) -> Void in
			completion?()
		}
	}
}
