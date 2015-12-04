//
//  NSCalendar+PMCalendarView.swift
//  PMCalendar
//
//  Created by Peymayesh on 9/13/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import UIKit

extension Array {
	func shiftRight(var amount: Int = 1) -> [Element] {
		assert(-count...count ~= amount, "Shift amount out of bounds")
		if amount < 0 { amount += count }  // this needs to be >= 0
		return Array(self[amount ..< count] + self[0 ..< amount])
	}
	
	mutating func shiftRightInPlace(amount: Int = 1) {
		self = shiftRight(amount)
	}
}