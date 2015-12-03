# PMCalendarView

PMCalendar View is a fork of <a href="https://github.com/nbwar/NWCalendarView/issues">NWCalendarView</a> Project, an IOS control that displays a calendar. It is perfect for appointment or availibilty selection. It allows for selection of a single date or a range. It also allows to disable dates that are unavailable.

<p align="center">
  <img src="http://i.imgur.com/XsIX6F6.png" height=400 width=400/>
  <img src="http://i.imgur.com/0Mflkvb.png" height=400 width=400/>
</p>


## Customization
You can change your calendar and locale and create calendar you want.
```swift
let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierPersian)!
let locale = NSLocale(localeIdentifier: "fa_IR")
```

Make sure to call `createCalendar()` setting your custom options


**disable dates**
```swift
// Takes an array of NSDates
calendarView.disabledDates = [newDate, newDate2, newDate3]
```

**Set Max Months**

You may only want to allow going 4 months into the future
```swift
calendarView.maxMonths = 4
```

**Set selection Range** (defaults to 0 - no selection)

```swift
selectionRangeLength = 7
```

## Delegate

**didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents)**
```swift
func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents) {
  print("Change From month \(fromMonth) to month \(toMonth)")
}
```

**didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents)**
```swift
func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents) {
  print("Selected date \(fromDate.date!) to date \(toDate.date!)")
}
```
**Feel free to edit! :D**
