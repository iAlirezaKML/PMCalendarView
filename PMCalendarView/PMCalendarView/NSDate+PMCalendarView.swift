//
//  NSDate+PMCalendarView.swift
//  PMCalendar
//
//  Created by Peymayesh on 9/13/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
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