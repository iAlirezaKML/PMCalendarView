//
//  NSDate+PMCalendarView.swift
//  PMCalendar
//
//  Created by Alireza Kamali on 12/1/15.
//  Copyright © 2015 Alireza Kamali. All rights reserved.
//

import Foundation
import UIKit

extension NSDate {
  func PMCalendarView_dayWithCalendar(calendar: NSCalendar) -> NSDateComponents {
    return calendar.components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: self)
  }
  
  func PMCalendarView_monthWithCalendar(calendar: NSCalendar) -> NSDateComponents {
    return calendar.components([.Calendar, .Year, .Month], fromDate: self)
  }
  
  func PMCalendarView_dayIsInPast() -> Bool {
    return self.timeIntervalSinceNow <= NSTimeInterval(-86400)
  }
  
}