//
//  PMCalendarCache.swift
//  PMCalendar
//
//  Created by Peymayesh on 9/13/1394 .
//  Copyright © 1394 AP Peymayesh. All rights reserved.
//

import Foundation

class PMCalendarCache {
  static let sharedCache = PMCalendarCache()
  private var token: dispatch_once_t = 0
  
  var cache: NSCache!

  
  init() {
    dispatch_once(&token, {
      self.cache = NSCache()
    })
  }
  
  func objectForKey(key: AnyObject) -> AnyObject? {
    return cache.objectForKey(key)
  }
  
  func setObjectForKey(object: AnyObject, key: AnyObject) {
    cache.setObject(object, forKey: key)
  }
  
}